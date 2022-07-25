#!/bin/sh -ue
curl -vi $(terraform output -raw s3wwwurl)
