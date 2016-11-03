# FaceGroups Web API
[![Codeship status for aditya-utama-wijaya/facegroups-api](https://app.codeship.com/projects/5ea15e20-83a9-0134-b028-326642146a3a/status?branch=master)](https://app.codeship.com/projects/182863)

API to check for feeds and information on public Facebook Groups

## Routes

- `/` - check if API alive
- `/v0.1/groups/:group_id` - confirm group id, get name of group
- `/v0.1/groups/:group_id/feed` - get first page feed of a group
