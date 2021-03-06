# EMR Static HBase cluster
module "emr-hbase" {
  source = "git@github.com:Datatamer/terraform-aws-emr.git?ref=0.10.7"

  # Configurations
  create_static_cluster = true
  release_label         = "emr-5.29.0" # hbase 1.4.10
  applications          = ["Hbase", "Ganglia"]
  emr_config_file_path  = "./emr.json"
  additional_tags       = {}
  enable_http_port      = true
  bucket_path_to_logs   = "logs/${var.name_prefix}-hbase"

  # Networking
  subnet_id  = var.ec2_subnet_id
  vpc_id     = var.vpc_id
  tamr_cidrs = var.ingress_cidr_blocks
  tamr_sgs = [
    module.tamr-vm.tamr_security_groups["tamr_security_group_id"],
    module.tamr-es-cluster.es_security_group_id,
    module.rds-postgres.rds_sg_id
  ]

  # External resource references
  bucket_name_for_root_directory = module.s3-data.bucket_name
  bucket_name_for_logs           = module.s3-logs.bucket_name
  s3_policy_arns = [
    module.s3-logs.rw_policy_arn,
    module.s3-data.rw_policy_arn
  ]
  key_pair_name = module.emr_key_pair.this_key_pair_key_name

  # Names
  cluster_name                  = "${var.name_prefix}-HBase-Cluster"
  emrfs_metadata_table_name     = "${var.name_prefix}-HBase-EmrFSMetadata"
  emr_service_role_name         = "${var.name_prefix}-hbase-service-role"
  emr_ec2_role_name             = "${var.name_prefix}-hbase-ec2-role"
  emr_ec2_instance_profile_name = "${var.name_prefix}-hbase-emr-instance-profile"
  emr_service_iam_policy_name   = "${var.name_prefix}-hbase-service-policy"
  emr_ec2_iam_policy_name       = "${var.name_prefix}-hbase-ec2-policy"
  master_instance_group_name    = "${var.name_prefix}-HBaseMasterInstanceGroup"
  core_instance_group_name      = "${var.name_prefix}-HBaseCoreInstanceGroup"
  emr_managed_master_sg_name    = "${var.name_prefix}-EMR-HBase-Master"
  emr_managed_core_sg_name      = "${var.name_prefix}-EMR-HBase-Core"
  emr_additional_master_sg_name = "${var.name_prefix}-EMR-HBase-Additional-Master"
  emr_additional_core_sg_name   = "${var.name_prefix}-EMR-HBase-Additional-Core"
  emr_service_access_sg_name    = "${var.name_prefix}-EMR-HBase-Service-Access"

  # Scale
  master_group_instance_count = 1
  core_group_instance_count   = 4
  master_instance_type        = "m4.large"
  core_instance_type          = "r5.4xlarge"
  master_ebs_size             = 50
  core_ebs_size               = 200
}
