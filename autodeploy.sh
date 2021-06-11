#!/bin/bash
#set -x

#
# Скрипт ищет последнюю успешную job в cicd gitlab для ветки RELEASE_BRANCH
#

# Задайте переменные ниже
GITLAB_URL=https://gitlab.domain.com
GROUP=gitlab_group
RELEASE_BRANCH=release%2F2021.06
JOB_NAME="deploy prod"
PRIVATE_TOKEN=gitlabsecretttoken
PROJECTS=(
project1
project2
)

echo "Начинаем:"
echo "${PROJECTS[*]}"
for p in "${PROJECTS[@]}"; do
    printf '\nПроект: %s' "$p"
    PIPE_ID=$(curl -s --location --request GET "$GITLAB_URL/api/v4/projects/$GROUP%2F$p/pipelines?per_page=1&page=1&ref=$RELEASE_BRANCH" \
    --header 'Content-Type: application/json' \
    --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" | jq '.[0].id')
    echo "Pipeline ID: $PIPE_ID"


    JOB_ID=$(curl -s --location --request GET "$GITLAB_URL/api/v4/projects/$GROUP%2F$p/pipelines/$PIPE_ID/jobs" \
    --header 'Content-Type: application/json' \
    --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" | jq ".[] | select(.name | startswith($JOB_NAME)) | .id" | head -n 1)
    echo "Job ID: $JOB_ID"
    
    curl -s --request POST $GITLAB_URL/api/v4/projects/$GROUP%2F"$p"/jobs/"$JOB_ID"/play --header "PRIVATE-TOKEN: $PRIVATE_TOKEN"
    open "GITLAB_URL/$GROUP/$p/-/jobs/$JOB_ID"
done
