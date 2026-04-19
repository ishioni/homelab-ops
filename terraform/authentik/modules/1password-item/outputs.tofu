output "fields" {
  description = "A map of all fields that are available in the 1Password Item"
  sensitive = true
  value     = merge(
    {
      username = data.onepassword_item.item.username
      password = data.onepassword_item.item.password
    },
    merge([
      for section in data.onepassword_item.item.section : merge([
        for field in section.field :
          {
            "${field.label}" = field.type == "CONCEALED" ? sensitive(field.value) : field.value
          }
      ]...)
    ]...)
  )
}
