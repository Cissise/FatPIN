import random
import numpy as np
import math
import torch.nn as nn
import torch
from torch.nn import functional as F
from torch.distributions import Categorical  
import time
import matlab
import matlab.engine
import shutil
import os
import scipy.io as scio
import skfda

eng = matlab.engine.start_matlab()


eplison = 0.1
criterion = nn.CrossEntropyLoss()  
Epsilon = 0.9 # greedy policy
gamma = 0.9  # reward discount factor
actor_lr = 0.001
critic_lr = 0.01
batch_size = 1
Episode = 5
TEST = 10  
num_of_organ=12

def composite_approximator(f_beta,f_xt,a,b,n):
    def f_x(t):
        x=t
        return eval(f_beta)*(f_xt(x).ravel()) 

    #Compute integrals using the composite Simpson formula
    integ_approx=((b-a))/6*(f_x(a)+4*f_x(((a+b)/2))+f_x(b))

    return integ_approx

def intergration_form_fourier(functional_data,
                                                beta_basis=None, 
                                                num_fd_basis=None,  #the number of fd basis functions
                                                num_beta_basis=None,  #the number of bata basis functions
                                                domin_range=None):

    #### Setting up x_i(s) form ####
    grid_point=np.array(domin_range).squeeze()             
    data_matrix=np.array(functional_data)[np.newaxis,:]  
    basis = skfda.representation.basis.BSpline(n_basis = num_fd_basis)
    fd = skfda.FDataGrid(data_matrix=data_matrix,grid_points=grid_point)
    X_basis = fd.to_basis(basis)

    
    #### Setting up beta_(s) ####
    beta_basis_form = []
    beta_basis_form.append('1')

    for m in range(1,(num_beta_basis-1)//2+1):
        beta_basis_form.append(('np.sin(2*np.pi*x'+'*'+str(m)+'/'+str(domin_range[-1])+')'))
        beta_basis_form.append(('np.cos(2*np.pi*x'+'*'+str(m)+'/'+str(domin_range[-1])+')'))

    #### Getting approximations ####
    
    integ_approximations = []
    for m in range(len(beta_basis_form)):
    
        #calculate Φm(t)X(t)
        form_approximated = str(beta_basis_form[m])
        final_func = form_approximated

        integ_approximations.append(composite_approximator(f_beta=final_func,f_xt=X_basis,a=domin_range[0],b=domin_range[-1],n=5000))

    return integ_approximations

def func_to_state(functional_data,domin_range):
    num_fd_basis = 40
    num_beta_basis = 5 
    state = np.zeros((functional_data.shape[0],num_beta_basis))
    for i in range(functional_data.shape[0]):
        state[i,:] = intergration_form_fourier(functional_data[i,:],num_fd_basis=num_fd_basis,num_beta_basis=num_beta_basis,domin_range=domin_range)

    return state

class TP():
    def __init__(self, num_of_organ):
        self.action_space = np.array([0.98, 0.99, 1, 1.01, 1.02])   
        self.observation_space = np.random.randn(num_of_organ, 5) 

    # status update
    def step(self,file,action, dose, V18, D95):

        action = matlab.double([action.tolist()])
        #dose = matlab.double([dose.tolist()])
        V18 = matlab.double([V18.tolist()])
        D95 = matlab.double([D95.tolist()])

        result = eng.step_fda_multipatient(file,action, dose, nargout=5)


        f_data = np.array(result[0])              
        d_range = np.array(result[1]).squeeze()   
        dose_ = np.array(result[2])  
        V18_ = np.array(result[3])
        D95_ = np.array(result[4]).reshape(1,-1)

        V18 = np.array(V18)
        D95 = np.array(D95)


        if np.all(D95_[:] > D95[:]) and np.all(V18_[:] < V18[:]):
            reward = 10
        elif np.all(D95_[:] > D95[:]) :
            reward = 5
        elif np.all(V18_[:] < V18[:]):
            reward = 3
        else:
            reward = 0
        done = False

        if np.any(V18[:] >= 0.5) or np.any(D95_[:] < D95[:]):
            done = True

        info = {}

        return f_data, d_range, reward, dose_, done, V18_, D95_

    # Initialization state
    def reset(self, file,num_of_organ):
        dose = matlab.double([50]*num_of_organ)

        result = eng.reset_fda_multipatient(file,dose,nargout=4)
        functional_data = np.array(result[0])                                              
        domin_range = np.array(torch.FloatTensor(result[1])).squeeze()    
        D95 = np.array(torch.FloatTensor([result[3]]))
        V18 = np.array(torch.FloatTensor(result[2]).squeeze())


        return functional_data,domin_range, dose, V18, D95

    def render(self, mode='human'):
        pass

    def seed(self, seed=None):
        pass


# %%
class PGNetwork(nn.Module):

    # The function of PGNetwork is to input the state vector at a certain moment and output the probability of each action being adopted.
    def __init__(self, n_state, n_action):
        super().__init__()
        self.fc=nn.Sequential(nn.Linear(n_state, 128),nn.ReLU()
                              ,nn.Linear(128,64),nn.ReLU()
                              ,nn.Linear(64, n_action) 
        )


    def forward(self, x):
        action_scores = self.fc(x)
        output = F.softmax(action_scores, dim=1)  # probability
        return output

class Actor(object):
    def __init__(self, env):
        # initialization
        self.n_state = env.observation_space.shape[1]  

        self.n_action = env.action_space.shape[0]  

        self.network = PGNetwork(n_state=self.n_state, n_action=self.n_action)

        self.optimizer = torch.optim.Adam(self.network.parameters(), lr=actor_lr)

        self.criterion = nn.CrossEntropyLoss()

    def choose_action(self, observation):
        
        observation = torch.FloatTensor(observation)
      
        probs = self.network(observation)  

        # Generate distribution
        m = Categorical(probs)

        # Greedy Algorithm
        if np.random.uniform() < Epsilon:
            action = m.sample() #  Sampling from distribution
            action = torch.LongTensor(action).squeeze() 
        
        # Random Strategy
        else:
            action = np.random.randint(0, self.n_action,size=(14,1))
            action = torch.LongTensor(action).squeeze()

        return action

    def learn(self, observation, action, td_error):

        #state
        observation = torch.FloatTensor(observation) 

        # Probability
        softmax_input = self.network(observation)    

        action = torch.LongTensor(action)            

        neg_log_prob = self.criterion(input=softmax_input, target=action)

        loss_a = -neg_log_prob * td_error


        self.optimizer.zero_grad()
        loss_a.backward(torch.ones_like(loss_a)) 
        self.optimizer.step()


class QNetwork(nn.Module):
    def __init__(self, n_state, n_action):
        super(QNetwork, self).__init__()

        self.fc = nn.Sequential(nn.Linear(n_state, 128),nn.ReLU(inplace=True),
                              nn.Linear(128, 64),nn.ReLU(inplace=True),
                              nn.Linear(64,1)
                              )

    def forward(self, x):
        state_value = self.fc(x)
        return state_value

class Critic(object):
    def __init__(self, env):
        self.n_state = env.observation_space.shape[1] 

        self.n_action = env.action_space.shape[0]     

        self.network = QNetwork(n_state=self.n_state, n_action=self.n_action)

        self.optimizer = torch.optim.Adam(self.network.parameters(), lr=critic_lr)

        self.loss_func = nn.MSELoss()

    def learn(self, state, reward, state_):
        
        # state s, s_
        s  = torch.FloatTensor(state)  
        s_ = torch.FloatTensor(state_) 

        # reward r
        r  = torch.FloatTensor([reward]) 

        # Get the value v, v_ of s, s_
        v = self.network(s)    # v(s)
        v_ = self.network(s_)  # v(s_)

        # TD
        loss_q = self.loss_func(r + gamma * v_, v)

        self.optimizer.zero_grad()
        loss_q.backward()
        self.optimizer.step()

        with torch.no_grad():
            td_error = r + gamma * v_ - v

        return td_error



def main():

    #os.mkdir('./result/test_info')

    # Instantiation Environment
    env = TP(num_of_organ=12)
    
    #loading model
    actor_test=torch.load('./result/actor/multi_20_20.pth',map_location=None)

    file = 'test_patient.mat'
    
    for episode in range(Episode):
        
        ##Initialize the environment
        f_data,d_range, dose, V18, D95 = env.reset(file,num_of_organ=12) 

        state = func_to_state(f_data, d_range)
        
        reward_total = 0

        print("Initialization completed, Round No. {0} begins".format(episode))

        for i_test in range(30):
            # select actions
            action_index = actor_test.choose_action(state) 
            action = env.action_space[action_index]   

            #interact with MATLAB
            functional_data, domin_range, reward, dose_, done, V18_, D95_ = env.step(file,action, dose, V18, D95)
            
            #state conversion
            state_ = func_to_state(functional_data,domin_range)
            reward_total += reward

            print('Step {} --- Action {}--- Reward {}'.format(i_test, action, reward))

            state = torch.FloatTensor(state).unsqueeze(dim=0).unsqueeze(dim=0)
            state_ = torch.FloatTensor(state_).unsqueeze(dim=0).unsqueeze(dim=0)


            with open('./result/test_info/test_{}_rounds'.format(episode) + '.csv','a',encoding='utf-8') as f:
                f.write(' The {}th test'.format(i_test)
                +' dose is '+','.join(map(str,np.array(dose).reshape(1,-1)))
                +' V18 is '+str(np.array(V18_).reshape(1,-1))
                +' D95 is '+str(np.array(D95_).reshape(1,-1))
                +' reward is '+str(np.array(reward).reshape(1,-1))
                +' total reward is '+str(np.array(reward_total).reshape(1,-1))
                +'\n')
                
            state = state_
            dose = matlab.double(dose_.tolist())
            V18 = V18_
            D95 = D95_

if __name__ == "__main__":
    main()
