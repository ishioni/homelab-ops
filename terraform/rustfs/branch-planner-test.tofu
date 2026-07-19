module "branch_planner_test" {
  source      = "./modules/rustfs"
  bucket_name = "branch-planner-test"
  create_user = false
}
