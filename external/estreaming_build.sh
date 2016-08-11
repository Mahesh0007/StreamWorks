#!/bin/sh

cd $(dirname $0)

clean=$1

#
# clone estreaming project and adjust it for streamworks
#
# rm -fr estreaming/

# go get the code from estreaming repo
if [[ "$clean" == '--clean' || ! -d 'estreaming' ]]; then

  git clone --depth 1 https://github.com/petergdoyle/estreaming.git

  echo "making runtime modifications..."
  # rename the docker images and containers in all build and run scripts
  find estreaming -type f -exec sed -i 's/estreaming_/streamworks_/g' {} \;
  find estreaming -type f -exec sed -i 's$estreaming/$streamworks/$g' {} \;
  find estreaming -type f -exec sed -i "s/'estreaming'/'streamworks'/g" {} \;

  # don't need ibm mq support
  # get rid of the mq code or its a pain to get working without a running mq container
  for each in $(find estreaming -iname '*java' -type f -exec grep -l 'ibm' {} \;); do
    mv "$each" "$each".bak
  done
  # get rid of the mq dependencies
  # hack alert! hack alert! -delete the dependency entry in pom by hard coded line numbers
  sed -i '73,77d' estreaming/message-sender/MessageSender/pom.xml

  # make the build and run scripts runnable from the streamworks base folder
  sed -i '/#!\/bin\/sh/a cd $(dirname $0)'  estreaming/docker/base/docker_build.sh
  sed -i '/#!\/bin\/sh/a cd $(dirname $0)'  estreaming/docker/jdk8/docker_build.sh

  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/kafka/singlenode/docker_build.sh
  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/kafka/singlenode/docker_run_zk.sh
  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/kafka/singlenode/docker_run_broker.sh

  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/mongo/docker_build.sh
  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/mongo/docker_run_mongodb_server_native.sh

  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/message-sender/MessageSender/runMessageSenderRunner.sh
  sed -i '/#!\/bin\/sh/a cd $(dirname $0)' estreaming/message-receiver/MessageReceiver/run_kafka_consumer.sh

  # provide param configured scripts rather than interactive scripts for demo
  cp streamworks_run_message_sender.sh estreaming/message-sender/MessageSender/
  cp streamworks_run_splash_csv_console_listener_1.sh estreaming/message-receiver/MessageReceiver/
  cp streamworks_run_splash_json_console_listener_1.sh estreaming/message-receiver/MessageReceiver/
  cp streamworks_kafka_docker_build.sh estreaming/kafka/singlenode/

fi
