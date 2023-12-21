# attention! enter the folder: scripts and then run this bash.


# ------------ INPUT PART ------------------------------------------


# for cl-ecbs
method="CL-CBS"


planner="../build/${method}"

input_path="../benchmark/cases/obs8/"
num_agent='16'
batch_size='16'
weight='20'

# TODO can I replace the w2 by command using ${weight} ?
# output_path="../results/cases/obs8/${method}/dt0dot7b${batch_size}/"
output_path="../results/cases/obs8/${method}/dt1b${batch_size}/"



# specific the core numbers to run the script.
num_procs=6
# ------------ INPUT PART ENDED --------------------------------

# ------------------ AUTO BASH PART -----------------------------

subfolderForPath=${output_path}${output_fname}
mkdir -p ${subfolderForPath}

num_jobs="\j"  # The prompt escape for number of jobs currently running


for fname_with_path in ${input_path}*.yaml; do
    # split by the slash
    IFS='/' read -ra ADDR <<< "${fname_with_path}"
  
    # get the name without path. 
    # 4 表示数组中的第5个元素。数组由fname_with_path 分割/产生
    fname_with_suffix=${ADDR[4]} 
    output_fname=${fname_with_suffix}

    echo "proccess:"
    echo ${fname_with_suffix}

    # echo ../PriorityPlanner/build/pbs -m "${input_path}${fname}".map -a "${input_path}${fname}".scen -k 50 -o "${output_path}${fname}".csv --outputPaths="${output_path}${fname}".txt -t 10 &
    
    while (( ${num_jobs@P} >= $num_procs )); do
        wait -n
    done

    ${planner} -i "${input_path}${fname_with_suffix}" \
        -o "${output_path}${output_fname}" \
        -b ${batch_size} &
        # -w ${weight}  
        
done
wait

echo "------------------all the instances are processed!---------------"
printf "\n"