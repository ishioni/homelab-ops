return {
    # Because authentik only saves the user's full name, and has no concept of first and last names,
    # the full name is used as given name.
    # You can override this behaviour in custom mappings, i.e. `request.user.name.split(" ")`
    "name": request.user.name,
    "given_name": request.user.name,
    "preferred_username": request.user.username,
    "nickname": request.user.username,
    "groups": [group.name for group in request.user.ak_groups.all()],
    "picture": user.attributes.get("avatar"),
    "quota": user.attributes.get("storageQuota",user.group_attributes().get("storageQuota"))
}
