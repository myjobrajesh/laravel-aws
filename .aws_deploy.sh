echo "Start"

if [ -n "$1" ]; then
  MSG_INPUT=' - '${1}
else
  MSG_INPUT=''
fi

BRANCH=$(git branch | grep "*")
CURRENT_BRANCH=${BRANCH:2}
MSG='Branch- '${CURRENT_BRANCH}${MSG_INPUT}
echo ${MSG}
ENV_MAIN_FILE=.ebextensions/02env_vars.config
NOW=$(date +"%d-%b-%Y-%H-%M")
WORKER_ENV='worker'

# if current branch is master then it should pushed to production
if [ "${CURRENT_BRANCH}" == "master" ]; then
        ENV_NAME='production'
        LBL=${ENV_NAME}'-'${NOW}

        echo "Environment : ${ENV_NAME}"

        ENV_FILE=.ebextensions/env_vars.config.production
        #copy production file  content nad paste in main config.

        cp ${ENV_FILE} ${ENV_MAIN_FILE}

        eb deploy ${ENV_NAME} --label ${LBL} --message "${MSG}"

        echo "Worker Env running:"
        LBL=${WORKER_ENV}'-'${NOW}
        eb deploy ${WORKER_ENV} --label ${LBL} --message "${MSG}"
else
        # change this environmnt after staging.
        ENV_NAME='Staging'
        LBL=${ENV_NAME}'-'${NOW}

        echo "Environment : "${ENV_NAME}
        #copy staging file content nad paste in main config.
        ENV_FILE=.ebextensions/env_vars.config.staging

        cp ${ENV_FILE} ${ENV_MAIN_FILE}

        eb deploy ${ENV_NAME} --label ${LBL} --message "${MSG}"

        #after testing this will be removed as this is not required on staging.
        #TODO:: will seperate worker env in future.
        echo "Worker Env running:"
        LBL=${WORKER_ENV}'-'${NOW}
        eb deploy ${WORKER_ENV} --label ${LBL} --message "${MSG}"

fi

echo "Deployment end"
