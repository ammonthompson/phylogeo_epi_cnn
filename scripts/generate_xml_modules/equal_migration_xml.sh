#!/bin/bash
# this is a private script that is used by the generate_X_xml.sh scripts

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
        index=0
        for m in $(seq 1 ${#pop[@]});do
                for n in $(seq 1 ${#pop[@]});do

                        if [[ ! $m -eq $n ]];then

                                no_m_f=$( get_migration_btwn $((m-1)) $((n-1)) )
                                m2n_rate=$(echo $no_m_f \* $migration_rate_scale | bc -l )
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
        index=0
        for m in $(seq 1 ${#pop[@]});do
                for n in $(seq 1 ${#pop[@]});do

                        if [[ ! $m -eq $n ]];then

                                no_m_f=$( get_migration_btwn $((m-1)) $((n-1)) )
                                m2n_rate=$(echo $no_m_f \* $migration_rate_scale | bc -l )
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
