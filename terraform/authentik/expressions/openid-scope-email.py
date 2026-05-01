return {
    "email": request.user.email,
    "email_verified": request.user.attributes.get("email_verified", False),
}
