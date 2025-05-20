iters=$1
sleep_time=$2
while (( iters-- >= 0 )); do
  sleep $sleep_timeó

	aws lambda invoke \
  --function-name graal-jfr-demo \
  --cli-binary-format raw-in-base64-out \
  --payload '"test"' \
  out.json
done
