locals {
  suffix = random_id.suffix.hex

  rg_name      = "${var.name_prefix}-rg-${local.suffix}"
  storage_name = replace("${var.name_prefix}storage${local.suffix}", "-", "")
  kv_name      = "${var.name_prefix}-kv-${local.suffix}"
  func_name    = "${var.name_prefix}-func-${local.suffix}"
}
