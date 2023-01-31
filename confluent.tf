resource "random_id" "env_display_id" {
    byte_length = 4
}

resource "confluent_environment" "env" {
    display_name = "flowers-env-${random_id.env_display_id.hex}"
}

resource "confluent_kafka_cluster" "basic_cluster" {
    display_name = "realtime-dwh-cluster"
    availability = "SINGLE_ZONE"
    cloud = "AWS"
    region = "eu-central-1"
    basic {}
    environment {
        id = confluent_environment.env.id
    }
}

# Accounts:
# JDBC Account
# MongoDB Account
# Stream Processing
resource "confluent_service_account" "jdbc_manager" {
    display_name = "jdbc-manager-service-account-${random_id.env_display_id.hex}"
    description = "Created by Terraform"
}
resource "confluent_service_account" "mongodb_manager" {
    display_name = "mongodb-manager-service-account-${random_id.env_display_id.hex}"
    description = "Created by Terraform"
}
resource "confluent_service_account" "streamprocessing_manager" {
    display_name = "streamprocessing-manager-service-account-${random_id.env_display_id.hex}"
    description = "Created by Terraform"
}