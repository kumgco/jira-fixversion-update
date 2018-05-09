#!/bin/bash
JIRAURL='https://<YOURCOMPANY>.atlassian.net'
JQL='project="SK"+AND+Status="Closed"'
MAXRESULTS='500'
FIELDS=SK
NOTIFYUSERS=false
 
function query {
curl -H "Accept:application/json" -u "$1":"$2" -X GET -H "Content-Type: application/json" "$JIRAURL/rest/api/2/search?jql=$JQL&maxResults=$MAXRESULTS&fields=$FIELDS"
}
 
function updateIssue {
curl -D- -u "$1":"$2" -X PUT --data @input.json -H "Content-Type: application/json" "$JIRAURL/rest/api/2/issue/$3?notifyUsers=$NOTIFYUSERS"
}
 
echo "Enter JIRA user"
read USERNAME
echo "Enter JIRA password"
read PWD
 
echo -e "Starting"
query $USERNAME $PWD > output.json
 
echo "Updaing jira issues"
 
TOTAL=`jq '.total' output.json`
COUNTER=0
INDEX=0
while [ $COUNTER -lt 1 ]; do
 PARAM='.issues['$INDEX'].key'
 OUTPUT=`jq $PARAM output.json | sed -e 's/\"//g'`
 
 if [ "$OUTPUT" != "null" ]; then
 echo "$OUTPUT"
 let INDEX=INDEX+1
 if [ "$1" == "update" ]; then
 echo "updating "$OUTPUT"..."
 
 updateIssue "$USERNAME" "$PWD" "$OUTPUT"
 
 echo "done"
 sleep 10
 fi
 else
 echo Total returned items: ""$TOTAL" out of a maximum of "$MAXRESULTS""
 exit
 fi
done
