#!/bin/bash
(export FNCS_LOG_STDOUT=yes && exec fncs_broker 3 &> broker30.log &)
(export FNCS_FATAL=YES && export FNCS_LOG_STDOUT=yes && exec gridlabd -D USE_FNCS inv30.glm &> gridlabd30.log &)
(export FNCS_FATAL=YES && export FNCS_LOG_STDOUT=yes && exec fncs_player 48h prices.player &> player30.log &)
(export FNCS_CONFIG_FILE=inv30_precool.yaml && export FNCS_FATAL=YES && export FNCS_LOG_STDOUT=yes && exec python -c "import tesp_support.api as tesp;tesp.precool_loop(48,'inv30')" &> precool30.log &)

