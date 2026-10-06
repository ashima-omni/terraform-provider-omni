# Connections. A change here is a credential or warehouse change.

connections = {
  "embed-base" = {
    dialect = "snowflake"

    # Account identifier, <org>-<account>, not the locator and not a URL.
    host = "pojcdlp-ja12247"

    database       = "SNOWFLAKE_SAMPLE_DATA"
    default_schema = "TPCH_SF1"
    scratch_schema = "OMNI_SCRATCH.PUBLIC"
    warehouse      = "OMNI_WH"
    username       = "OMNI_SVC"

    # The access floor. NO_ACCESS so that per-model grants decide access, and
    # so revoking a role assignment actually revokes it.
    base_role = "NO_ACCESS"

    refresh_schedule = {
      cron     = "0 2 * * ? *"
      timezone = "Australia/Melbourne"
    }
  }

  # A tenant with its own schema, for physical isolation. Remove this and the
  # initech entry in tenant_routing if every tenant shares embed-base.
  "embed-initech" = {
    dialect        = "snowflake"
    host           = "pojcdlp-ja12247"
    database       = "SNOWFLAKE_SAMPLE_DATA"
    default_schema = "TPCH_SF10"
    scratch_schema = "OMNI_SCRATCH.PUBLIC"
    warehouse      = "OMNI_WH"
    username       = "OMNI_SVC"
    base_role      = "NO_ACCESS"
  }

  "warehouse" = {
    dialect        = "snowflake"
    host           = "pojcdlp-ja12247"
    database       = "SNOWFLAKE_SAMPLE_DATA"
    default_schema = "TPCH_SF1"
    scratch_schema = "OMNI_SCRATCH.PUBLIC"
    warehouse      = "OMNI_WH"
    username       = "OMNI_SVC"

    # Internal users get access through model roles on their groups, so the
    # floor stays shut here too.
    base_role = "NO_ACCESS"

    refresh_schedule = {
      cron     = "0 2 * * ? *"
      timezone = "Australia/Melbourne"
    }
  }
}
