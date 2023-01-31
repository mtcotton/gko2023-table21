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

resource "confluent_ksql_cluster" "ksql_cluster" {
    display_name = "ksql-cluster-${random_id.env_display_id.hex}"
    csu = 1
    environment {
        id = confluent_environment.env.id
    }
    kafka_cluster {
        id = confluent_kafka_cluster.basic_cluster.id
    }
    credential_identity {
        id = confluent_service_account.streamprocessing_manager.id
    }
    depends_on = [
        # Role bindings, api keys
    ]
}

resource "confluent_connector" "mssql-connector" {
    environment {
        id = confluent_environment.env.id
    }
    kafka_cluster {
        id = confluent_kafka_cluster.basic_cluster.id
    }

    config_sensitive = {
        "kafka.api.key"         = "TODO"
        "kafka.api.secret"      = "TODO"
        "database.hostname"     = "TODO"
        "database.user"         = "TODO"
        "database.password"     = "TODO"
    }

    config_nonsensitive = {
        "connector.class"       = "SqlServerCdcSource"
        "name"                  = "SqlServerCdcSourceConnector_${random_id.env_display_id.hex}"
        "kafka.auth.mode"       = "KAFKA_API_KEY"
        "database.port"         = "1433"
        "database.dbname"       = "database-name"
        "database.server.name"  = "sql"
        "table.include.list"    = "public.passengers"
        "snapshot.mode"         = "initial"
        "output.data.format"    = "JSON"
        "tasks.max"             = "1"
    }
}
