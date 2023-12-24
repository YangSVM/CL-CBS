# attention! enter the folder: scripts and then run this bash.


# ------------ INPUT PART ------------------------------------------

# for cl-cbs
method="CL-CBS"
planner="../build/${method}"


## declare an array variable
declare -a num_agents_arr=("25" "30" "35" "40" "50")
for num_agent in "${arr[@]}"
do
# num_agent='50'
    obstacle=true
    map_size="100"  # 50 100 300
    kb=${num_agent}  # number of batch
    overwrite=true

    # specific the core numbers to run the script.
    num_procs=12
    # ------------ INPUT PART ENDED --------------------------------

    # ------------------ AUTO BASH PART -----------------------------
    if [ ${obstacle} = true ];
    then
        input_path="../benchmark/map${map_size}by${map_size}/agents${num_agent}/obstacle/"
        output_path="../results/map${map_size}by${map_size}/agents${num_agent}/obstacle/kb${kb}/"
    else
        input_path="../benchmark/map${map_size}by${map_size}/agents${num_agent}/empty/"
        output_path="../results/map${map_size}by${map_size}/agents${num_agent}/empty/kb${kb}/"
    fi

    ((batch_size = num_agent/kb))  # batch_size: number of agents per batch.
    echo "batch size: "${batch_size}
    echo "input path: "${input_path}
    echo "output path: "${output_path}

    subfolderForPath=${output_path}${output_fname}
    mkdir -p ${subfolderForPath}

    num_jobs="\j"  # The prompt escape for number of jobs currently running


    for fname_with_path in ${input_path}*.yaml; do
        # split by the slash
        IFS='/' read -ra ADDR <<< "${fname_with_path}"
    
        # get the name without path. 
        # 4 表示数组中的第5个元素。数组由fname_with_path 分割/产生
        fname_with_suffix=${ADDR[5]} 
        output_fname=${fname_with_suffix}

        if [ ${overwrite} = false ] && [ test -f "${output_path}${output_fname}"];
        then
            continue
        fi

        echo "proccess:"
        echo ${fname_with_suffix}

        # echo ../PriorityPlanner/build/pbs -m "${input_path}${fname}".map -a "${input_path}${fname}".scen -k 50 -o "${output_path}${fname}".csv --outputPaths="${output_path}${fname}".txt -t 10 &
        
        while (( ${num_jobs@P} >= $num_procs )); do
            wait -n
        done

        ${planner} -i "${input_path}${fname_with_suffix}" \
            -o "${output_path}${output_fname}" \
            -b ${batch_size}  &
    done
    wait
done

echo "------------------all the instances are processed!---------------"
printf "\n"