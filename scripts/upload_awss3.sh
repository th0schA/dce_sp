

# delete everything existing in both folders

aws s3 rm s3://dcesp/cards --recursive
aws s3 rm s3://dcesp/jsons --recursive


# cards
aws s3 cp /Users/thoscha/polybox/1_PhD/dce_sp/dce_sp/data/cards/. s3://dcesp/cards --acl public-read --recursive

# jsons
aws s3 cp /Users/thoscha/polybox/1_PhD/dce_sp/dce_sp/data/jsons/. s3://dcesp/jsons --acl public-read --recursive


