data "template_file" "mongo" {
  template = "${./service_configuration.json}"
}


data "mongodbatlas_cluster" "this"{
    project_id = var.mongoatlas_project_id
}

data "mongodbatlas_cluster" "this"{
    for_each = toset(data.mongodbatlas_cluster.this.result[*].name)
    project_id = var.mongoatlas_project_id
    name = each.value

    connection_strings = {
        for serviceName in var.service_configuration:
        "mongodb+srv://""${mongodbatlas_database_user.dbuser}":"${random_password.store-service-password}"@"${mongodbatlas_cluster.cluster.name}"/"${each.value.mongooDatabase}"/"${roles.value}"
    }
}

resource "random_password" "store-srevice-password"{
    count = 1
    length = 16
    special = true
}

resource "mongodbatlas_database_user" "dbuser"{
    username = "${var.environment}-${each.key}"
    password = random_password.store-srevice-password
    project_id = "<PROJECT-ID>"
    auth_auth_databse_name = "admin"

    dynamic roles{
        for_each = each.value.mongoCollection[*]
        content {
            role_name = "read"
            database_name = each.value.mongooDatabase
            collection_name = roles.value
        }
    }
}
