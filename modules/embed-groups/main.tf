# Tenant groups, and what they can do with data.
#
# A group is what the "groups" claim in a signed URL resolves to. Creating one
# implies nothing about folders or routing: those are separate concerns and
# separate modules.
#
# These are NOT the groups on the Embed tab of the Groups settings page. Omni
# has two kinds, and only one can be created:
#
#   Entity groups appear under Embed, one per value of the "entity" URL
#   parameter, created by the session itself along with a shared folder named
#   after the entity. There is no creation endpoint, so Terraform cannot make
#   them. Creating one by name here would produce a Standard group that merely
#   shares the name - a different object, resolving differently.
#
#   Non-entity groups are what the "groups" claim takes; the embed docs call
#   them that, and say entity membership is handled by "entity" instead. They
#   are ordinary user groups over SCIM, and they are what this module creates.
#
# One consequence for content_access: an entity's shared folder only exists
# after that entity's first session, so a grant on it has to go through
# existing_folders, and the data source fails at plan time until a session has
# created it. Terraform can neither create that folder nor wait for it.

terraform {
  required_providers {
    omni = {
      source = "ashima-omni/omni"
    }
  }
}

resource "omni_user_group" "tenant" {
  for_each = var.tenants

  # The key is the tenant's identity and never changes; display_name is the
  # label and can. Omni renames a group in place, while changing the key moves
  # the resource address, so Terraform destroys and recreates it and the
  # group's embed membership goes with it.
  display_name = coalesce(each.value.display_name, "${var.prefix}${each.key}")

  # Deliberately no member_ids. Embed sessions create their own users, and
  # membership here is authoritative, so Terraform would remove whoever the
  # session added.
}

# Optional: what the group can do with data. Skipped for a tenant with no
# model, which is the right default when access comes from a shared grant
# elsewhere.
#
# The filter is on grant_model_role, not on model_id. A model_id usually comes
# from a model Terraform is creating in the same run, so it is unknown until
# apply, and Terraform refuses a for_each whose set of keys it cannot work out
# at plan time. grant_model_role is set from configuration, so the keys are
# known and only the values arrive late.
resource "omni_user_group_model_role" "tenant" {
  for_each = {
    for k, v in var.tenants : k => v if v.grant_model_role
  }

  user_group_id = omni_user_group.tenant[each.key].id
  model_id      = each.value.model_id
  connection_id = each.value.connection_id
  role_name     = each.value.model_role
}
