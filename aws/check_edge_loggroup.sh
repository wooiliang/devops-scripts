FUNCTION_NAME=function-name
# aws --output text  logs describe-log-groups --log-group-name-pattern "$FUNCTION_NAME" --region us-east-1
# aws --output text  ec2 describe-regions | cut -f 4
for region in $(aws --output text  ec2 describe-regions | cut -f 4) 
do
    for loggroup in $(aws --output text  logs describe-log-groups --log-group-name-pattern "$FUNCTION_NAME" --region $region --query 'logGroups[].logGroupName')
    do
        echo $region $loggroup
    done
done
