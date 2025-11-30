# As of now we only have vetted users,
# so we can safely return true here
return {"email": request.user.email, "email_verified": True}
