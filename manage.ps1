param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("init", "plan", "apply", "destroy", "lint")]
  [string]$Action
)

switch ($Action) {
  "init"    { terraform init }
  "plan"    { terraform plan }
  "apply"   { terraform apply -auto-approve }
  "destroy" { terraform destroy -auto-approve }
  "lint"    { terraform fmt -recursive; terraform validate }
}
