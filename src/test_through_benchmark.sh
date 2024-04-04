# attention! enter the folder: scripts and then run this bash.


# ------------ INPUT PART ------------------------------------------

# for cl-cbs
method="CL-CBS"
planner="../build/${method}"

#fixed_batch_size=true  # true: fixed num of agents per batch. false: fixed num of batches.
#batch_size=1

fixed_batch_size=false  # true: fixed num of agents per batch. false: fixed num of batches.
kb=2

time_limit=20
## declare an array variable
#declare -a num_agents_arr=("5" "10" "15" "20" "25") # for map 50x50
#declare -a num_agents_arr=("25" "30" "35" "40" "50" )
declare -a num_agents_arr=("25" "30" "35" "40" "50" "60" "70" "80" "90" "100"  )
#declare -a num_agents_arr=("25")
#declare -a num_agents_arr=("60" "70" "80" "90" "100"  )
for num_agent in "${num_agents_arr[@]}"
do
    #obstacle=true
    obstalce_arr=(true false)
    for obstacle in "${obstalce_arr[@]}"
    do


      map_size="100"  # 50 100 300
      overwrite=true

      if [ ${fixed_batch_size} = true ];
      then
          ((kb = num_agent/batch_size))
          outprefix="batch_size_"${batch_size}
      else
          ((batch_size = num_agent/kb))  # batch_size: number of agents per batch.
          outprefix="kb"${kb}
      fi

      # specific the core numbers to run the script.
      num_procs=30
      # ------------ INPUT PART ENDED --------------------------------

      # ------------------ AUTO BASH PART -----------------------------
      if [ ${obstacle} = true ];
      then
          input_path="../benchmark/map${map_size}by${map_size}/agents${num_agent}/obstacle/"
          output_path="../results/${outprefix}/map${map_size}by${map_size}/agents${num_agent}/obstacle/"
      else
          input_path="../benchmark/map${map_size}by${map_size}/agents${num_agent}/empty/"
          output_path="../results/${outprefix}/map${map_size}by${map_size}/agents${num_agent}/empty/"
      fi

      echo "num of agents per batch. batch size: "${batch_size}
      echo "num of batches. kb: "${kb}
      echo "input path: "${input_path}
      echo "output path: "${output_path}

      subfolderForPath=${output_path}
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

          echo ${planner} -i "${input_path}${fname_with_suffix}" -o "${output_path}${output_fname}" -b ${batch_size} -t ${time_limit} 
          while (( ${num_jobs@P} >= $num_procs )); do
              wait -n
          done

          ${planner} -i "${input_path}${fname_with_suffix}" \
              -o "${output_path}${output_fname}" \
              -b ${batch_size} -t ${time_limit} &
      done
      wait
    done
done

echo "------------------all the instances are processed!---------------"
printf "\n"
