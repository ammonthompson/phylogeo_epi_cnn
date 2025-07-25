#!/bin/bash
# this is a private script that is used by the generate_X_xml.sh scripts
# This private script is an auxiliary tool designed to compute and manage 
# migration reactions based on an epidemiological model specified by the user.
# Specifically, it deals with the SIR (Susceptible, Infected, Recovered) model.
# When given migration parameters, it computes migration rates between 
# different locations, accommodating various aspects such as distance between 
# the locations and potential barriers to migration.
#
# The main tasks executed by the script include:
# - Calculating pairwise distances between locations using their X and Y positions.
# - Deriving migration rates between locations using distance and other parameters.
# - Outputting reactions for migration events in the model.
# - Supporting a 'superspreader' mode, accounting for high-infectious individuals.
#
# Input:
# The script takes in an epidemiological model ('SIR' in this context) and 
# other parameters specified in the parent script.
#
# Note:
# This script is not meant to be executed independently. It is called and used 
# by the 'generate_X_xml.sh' script series.
#
# Dependencies:
# - BC: An arbitrary precision calculator language.


EPI_MODEL=$1

get_migration_btwn(){
        # $1 -> $2 ( from 1 to 2 )

        if [[ -n $(echo $no_migration_btwn |grep ':') ]];then
                migration_string=$(echo H${no_migration_btwn}H | grep -Eo [^0-9]${2}:${1}[^0-9]\|[^0-9]${2}:[^@]+,${1}[^0-9]\|[^0-9]${1}:${2}[^0-9]\|[^0-9]${1}:[^@]+,${2}[^0-9])
                if [[ -n $migration_string ]];then
                        m_factor=0
                else
                        m_factor=1
                fi
                echo $m_factor
        else
                echo 1
        fi
}



if [[ $EPI_MODEL == 'SIR' ]];then

##########################
### SIR: migration rxn ###
##########################
# unsclaed migration rates between two locations is 1/distance 
# this is then scaled by the migration_rate_scale x mean(1/distance)
# so that the average migration rate = migration_rate_scale (maybe rename this to average_migration_rate).
if [[ $numLocs -gt 1 ]];then
        echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Migration\'\> >> $out_file
        pop=($(echo $initialPopSize_S |sed 's/,/ /g'))
        rate=($(echo $migration_rel_rate |sed 's/@/ /g'))
        posX=($(echo $position_x |sed 's/,/ /g'))
        posY=($(echo $position_y |sed 's/,/ /g'))
        declare -a pairwise_dist
        sum_of_inverse_distances=0
        index=0
        for m in $(seq 1 ${#pop[@]});do

                for n in $(seq 1 ${#pop[@]});do

                        if [[ ! m -eq n ]];then
                                pairwise_dist[$index]=$(echo sqrt\(\(${posX[$((m-1))]} \- ${posX[$((n-1))]}\) \^ 2 \+ \(${posY[$((m-1))]} \- ${posY[$((n-1))]}\) ^ 2 \) | bc -l)
                                sum_of_inverse_distances=$(echo $sum_of_inverse_distances + 1\/${pairwise_dist[$index]}|bc -l)
                                index=$((index+1))
                        fi

                done
        done
        avg_inverse_dist=$(echo $sum_of_inverse_distances \/ ${#pairwise_dist[@]}|bc -l)

        index=0
        for m in $(seq 1 ${#pop[@]});do
                for n in $(seq 1 ${#pop[@]});do

                        if [[ ! $m -eq $n ]];then

                                no_m_f=$( get_migration_btwn $((m-1)) $((n-1)) )
                                m2n_rate=$(echo $no_m_f \* $migration_rate_scale \* 1 / \( ${pairwise_dist[$index]} \) / $avg_inverse_dist | bc -l )
                                round_m2n_rate=$(round $m2n_rate 12 | sed -r 's/0+$//g')
                                echo  \<reaction spec=\'Reaction\' reactionName=\"Migration\" rate=\"${round_m2n_rate}\"\> $'\n' \
                                        $'\t'I[$((m-1))] -\> I[$((n-1))] \+ M_into_$((n-1))[$((m-1))] $'\n' \
                                                \<\/reaction\> >> $out_file

                                # if superspreader mode
                                if [[ ! $I2P_rate == FALSE && ! $I2P_rate == F && ! $I2P_rate == false && ! $I2P_rate == False ]];then

                                        echo  \<reaction spec=\'Reaction\' reactionName=\"Migration\" rate=\"${round_m2n_rate}\"\> $'\n' \
                                        $'\t'P[$((m-1))] -\> P[$((n-1))] \+ M_into_$((n-1))[$((m-1))] $'\n' \
                                                \<\/reaction\> >> $out_file
                                fi

                                index=$((index+1))

                        fi
                done
        done
        echo \<\/reactionGroup\> >> $out_file
fi # end SIR migration model



elif [[ $EPI_MODEL == 'SEIR' ]];then
###########################
### SEIR: migration rxn ###
###########################
# compute mean rate as a function of geographical distances. See Lemey et al. 2009.
if [[ $numLocs -gt 1 ]];then
        echo $'\n'\<reactionGroup spec=\'ReactionGroup\' reactionGroupName=\'Migration\'\> >> $out_file
        pop=($(echo $initialPopSize_S |sed 's/,/ /g'))
        rate=($(echo $migration_rel_rate |sed 's/@/ /g'))
        posX=($(echo $position_x |sed 's/,/ /g'))
        posY=($(echo $position_y |sed 's/,/ /g'))
        declare -a pairwise_dist
        sum_of_inverse_distances=0
        index=0
        for m in $(seq 1 ${#pop[@]});do

                for n in $(seq 1 ${#pop[@]});do

                        if [[ ! m -eq n ]];then
                                pairwise_dist[$index]=$(echo sqrt\(\(${posX[$((m-1))]} \- ${posX[$((n-1))]}\) \^ 2 \+ \(${posY[$((m-1))]} \- ${posY[$((n-1))]}\) ^ 2 \) | bc -l)
                                sum_of_inverse_distances=$(echo $sum_of_inverse_distances + 1\/${pairwise_dist[$index]}|bc -l)
                                index=$((index+1))
                        fi

                done
        done
        avg_inverse_dist=$(echo $sum_of_inverse_distances \/ ${#pairwise_dist[@]}|bc -l)

        index=0
        for m in $(seq 1 ${#pop[@]});do
                for n in $(seq 1 ${#pop[@]});do

                        if [[ ! $m -eq $n ]];then

                                no_m_f=$( get_migration_btwn $((m-1)) $((n-1)) )
                                m2n_rate=$(echo $no_m_f \* $migration_rate_scale \* 1 / \( ${pairwise_dist[$index]} \) / $avg_inverse_dist | bc -l )
                                round_m2n_rate=$(round $m2n_rate 12 | sed -r 's/0+$//g')
                                echo  \<reaction spec=\'Reaction\' reactionName=\"Migration\" rate=\"${round_m2n_rate}\"\> $'\n' \
                                        $'\t'I[$((m-1))] -\> I[$((n-1))] \+ M_into_$((n-1))[$((m-1))] $'\n' \
                                                \<\/reaction\> >> $out_file
                                echo  \<reaction spec=\'Reaction\' reactionName=\"Migration\" rate=\"${round_m2n_rate}\"\> $'\n' \
                                        $'\t'E[$((m-1))] -\> E[$((n-1))] \+ M_into_$((n-1))[$((m-1))] $'\n' \
                                                \<\/reaction\> >> $out_file

                                # if superspreader mode
                                if [[ ! $I2P_rate == FALSE && ! $I2P_rate == F && ! $I2P_rate == false && ! $I2P_rate == False ]];then

                                        echo  \<reaction spec=\'Reaction\' reactionName=\"Migration\" rate=\"${round_m2n_rate}\"\> $'\n' \
                                        $'\t'P[$((m-1))] -\> P[$((n-1))] \+ M_into_$((n-1))[$((m-1))] $'\n' \
                                                \<\/reaction\> >> $out_file
                                fi

                                index=$((index+1))

                        fi
                done
        done
        echo \<\/reactionGroup\> >> $out_file
fi #end SEIR migration model
fi
