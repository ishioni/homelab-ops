return {
    "nextcloudAdmin": user.attributes.get("nextcloudAdmin"),
    "nextcloudQuota": user.attributes.get("nextcloudQuota",user.group_attributes().get("defaultQuota", "100 MB"))
}
