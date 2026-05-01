prompt_data = request.context.setdefault("prompt_data", {})
prompt_data["attributes.email_verified"] = True
return True
