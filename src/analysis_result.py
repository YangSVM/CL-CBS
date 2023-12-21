'''
分析求解结果相关性能
'''
import yaml
from tqdm import tqdm
import numpy as np
from matplotlib import pyplot as plt


# 直接读取文件前几行的统计信息得出结果。而不使用yaml load
def fast_read_statistic(fname):
    with open(fname, "r") as f:
        f.readline() # "statistic"
        l = f.readline()
        cost = float(l.split()[1])
        l = f.readline()
        makespan = float(l.split()[1])
        l = f.readline()
        flowtime = float(l.split()[1])
        l = f.readline()
        runtime = float(l.split()[1])        
        # l = f.readline()
        # success = int(l.split()[1])
        
    return cost, makespan, flowtime, runtime


def calc_sucessful_rate(folder_path):
    # 分析求解结果的成功率
    num_success = 0
    for i_file in tqdm(range(1, 101)):
        is_successful = True
        try:
            with open( folder_path + str(i_file) +".yaml") as result_fid:
                res = yaml.load(result_fid, Loader=yaml.FullLoader)
                schedule = res['schedule']
                if len(schedule) < 16:
                    is_successful = False
                    continue
                for v in res['schedule'].values():
                    if len(v)<0:
                        is_successful = False
                        break
        except :
            is_successful = False
        if is_successful:
            num_success += 1
    print('successful num', num_success)
    return num_success

# 读取并对比成功率和计算时间
def analysis_success_runtime(ecbs_path, fname_prefix=""):
    # 分析求解结果的成功率
    num_success = 0
    success_list = []
    cost_list = []
    runtime_list = []

    for i_file in tqdm(range(0, 60)):
        is_successful = True
        cost = -1
        runtime = -1

        try:
            fname = ecbs_path + fname_prefix + str(i_file) + ".yaml"
            cost, _, _, runtime = fast_read_statistic(fname)
            is_successful = True

        except :
            print("read file", fname, "failed. Check file existence and format.")
            is_successful = False
        success_list.append(is_successful)
        cost_list.append(cost)
        runtime_list.append(runtime)

        if is_successful:
            num_success += 1
    print('successful num', num_success)
    success_list = np.array(success_list)
    cost_list = np.array(cost_list)
    runtime_list = np.array(runtime_list)
    
    return success_list, cost_list, runtime_list

def analyze_runtime(foler_path):
    # 分析求解时间的分布
    num_success = 0
    time = dict()
    for i_file in tqdm(range(1, 101)):
        try:
            with open( foler_path + str(i_file) +".yaml") as result_fid:
                res = yaml.load(result_fid, Loader=yaml.FullLoader)
                time[i_file] = res['statistics']['runtime']               
        except :
            pass
        
    times = np.array(list(time.values()))
    print('statistic information:')
    print('--mean value: ', times.mean())
    print('--median value: ', np.median(times))
    print('--max value: ', np.max(times))
    percent_tmp = 90
    print('--', percent_tmp,' % value: ', np.percentile(times, percent_tmp))   
    plt.hist(times)
    plt.title('runtime histogram')
    plt.xlabel('time/s')
    plt.ylabel('number')
    plt.show()

def analyze_distance(foler_path):
    # 分析单个智能体每一步的每个点之间的距离的分布
    end_file = 2

    delta_s= []
    for i_file in tqdm(range(1, end_file)):
        try:
            with open( foler_path + str(i_file) +".yaml") as result_fid:
                res = yaml.load(result_fid, Loader=yaml.FullLoader)
                schedule = res["schedule"]
                num_agent  = len(schedule.keys())
                for i_agent in range(num_agent):
                    path = schedule['agent'+str(i_agent)]
                    num_p = len(path)
                    for i_p in range(num_p):
                        if i_p == 0:
                            p0 = [path[i_p]['x'], path[i_p]['y']]
                        else:
                            p1  = [path[i_p]['x'], path[i_p]['y']]
                            d = ((p0[0]- p1[0])**2 + (p0[1]- p1[1])**2 )**0.5
                            delta_s.append(d)
                            p0 = p1

        except :
            pass
    delta_s = np.array(delta_s)


    print('statistic information:')
    print('--mean value: ', delta_s.mean())
    print('--median value: ', np.median(delta_s))
    print('--max value: ', np.max(delta_s))
    percent_tmp = 90
    print('--', percent_tmp,' % value: ', np.percentile(delta_s, percent_tmp))   
    plt.hist(delta_s)
    plt.title('runtime histogram')
    plt.xlabel('time/s')
    plt.ylabel('number')
    plt.show()

if __name__=='__main__':
    result_path = "/media/tiecun/Data/2_keyan/0codes/CL-CBS/results/map100by100/"
    
    folder = result_path + "dt0dot7b20w2_1115v3/"
    kb = 2
    num_agents = [25, 30, 35,40,50]
    runtimes_agents = []
    success_rates = []
    num_scene = 60
    for agents in num_agents:
        folder = result_path + 'agents' +  str(agents) + '/obstacle/kb' + str(2)+'/'
        fname_prefix = "map_100by100_obst50_agents"+str(agents)+"_ex"
        success_flags, costs, runtimes = analysis_success_runtime(folder, fname_prefix)
        runtimes_ = runtimes[success_flags]
        success_rate = success_flags.sum()/num_scene
        success_rates.append(success_rate)
        
        runtimes_agents.append(runtimes_)
        
    # for data in runtimes_agents:
    
    plt.boxplot(runtimes_agents)
    plt.show()
    print('success rates:', success_rates)
    print('done')

        

    # # calc_sucessful_rate(folder)
    # # analyze_runtime(folder)
    # # analyze_distance(folder)
    # success_flags, costs, runtimes = analysis_ecbs(folder)
    # print(np.mean(success_flags), np.mean(costs), np.mean(runtimes[runtimes<10]))


