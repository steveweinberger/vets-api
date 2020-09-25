# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :temp do
  namespace :vba_documents do
    desc(
      'An upstream DB is out of sync. That upstream partner has asked us if we could' \
      'update some statuses manually to vbms status. 2020-09-14'
    )

    task update_to_vbms_status: :environment do
      submissions_that_are_processing_in_cm_portal = %w[
        009cbb98-523f-4145-b37c-07f379fdd878
        0e560c1e-2bf2-4f0c-a392-e18209856e3a
        0efa0a13-1bc3-4992-b116-c98bc3650e53
        0f4a109d-3792-44cd-bd18-44f6308cbd2e
        12077845-24c7-4f74-a3b8-e20c40973155
        1f864997-8f8a-469d-98fd-6fd5102c35f8
        233f4116-e8d0-43ca-bd92-b052dcc62114
        2f09fafb-0747-4edf-8a91-0a7abffcb247
        3c723493-12e9-472d-9b19-b4384da94834
        3d21efa4-c5d8-4387-8a1f-23f103310b38
        7cc80332-ef80-4560-a46a-73d670019fe1
        7d9166d5-ea3e-4f75-bb8d-4e92e86c72af
        7de152bf-ce77-42d4-ae08-4f8e768aeeb3
        814b9cf5-cee3-4c77-823a-af83704bbc23
        814d6a3f-439c-47eb-80bb-037447a0f75c
        899ab539-67e3-466c-997e-56b38711ab8c
        901821c7-9338-49d1-bab5-bee6e7f55baa
        90ec2c05-ea32-4be9-8750-23695bd10fa6
        96c1e164-1cda-4a9e-b35d-d6225a867e91
        4232b749-af78-4523-99ea-f3080150a710
        433f2e09-b1f0-4e4d-a2de-cd4f2e222f0a
        470c2aa5-17f4-4db3-a4fb-8d35816a8e91
        48872730-403b-4316-aec2-96352d59b811
        4b9abf36-dfcf-412e-b0d3-49bc00c7952e
        4bc9a7b5-c3f7-4797-80d8-c2760696e200
        4c432e0f-49eb-4764-92f9-b39fa457d59b
        4ce19b29-d1c8-48d7-a366-58af5e51bb75
        538341d3-3f32-4014-999f-0835c76ed24e
        54b81ab3-a7a7-41e9-bcba-9b6eccfd5ec8
        5652c013-89c0-4d96-a90a-ef0440bae008
        5c6ada26-77dd-46d9-9bef-489c1b8c1686
        5db8a188-e7f5-4bec-ba25-10671dc8ec99
        638a13a7-802f-4e20-aef8-be509da53a51
        699d1c57-d028-4114-b119-7f6835d0961d
        6d8b0e44-39a2-48e6-aab3-9604cef2d3bd
        854afad9-bedf-4c93-8563-52e3cec0a85e
        85b4755e-5747-49b0-8f5d-111df8f5dfcc
        86b4ba89-50f5-4734-9bed-3c977068663b
        879146b8-e1d1-430b-8a5c-9f791dd3829a
        88873453-aa64-430f-b170-8b0ea2ccce89
        88bd7416-3961-4afa-b783-495e433a8ba2
        8a68b807-30c1-427b-a708-374b77c8db18
        8b9577e1-56aa-46f4-89f5-eec4967d91a3
        8c52cc87-d01a-45a5-9c55-412eb322e195
        8c5b976a-e59d-46d1-9dc9-eaff226020ed
        8c91dd38-db50-4811-9374-4f814cfb8108
        8cbeadc2-246b-4095-aee3-8aeccefdf953
        8f9d238f-dbfe-4fc8-926c-bdfcc54110d1
        917af235-c16e-400d-8c26-f9b823c7b76e
        9366f745-dfbd-4ea8-98a6-b3ce4727918a
        93a1e820-798d-460d-bef0-8e28d719525f
        93fb9153-71c9-4ba2-a18b-90adc9c9c235
        95555fd1-c388-4b95-87fd-54c1ef800439
        956d49da-7050-4916-b13c-db0c74f21478
        af9058c8-760a-492b-bb01-6cd8dcff233a
        b93edf2b-45a8-453f-bbd5-76d84a1162ef
        bd115ddb-19e2-487e-ac53-2facbf256692
        bed077c4-c1e8-4e2d-8f04-bee87e7429d1
        c2ef8682-99df-4912-81fa-7a920bed208c
        c8c3c004-069a-4463-b310-2809a222fb0f
        d317f875-18c6-43f9-b3ce-f9f552890124
        d3fb93ea-3308-45c2-a4ab-eba5fedf4ed8
        d47b1772-1c7a-4451-86b4-0d977ef9f6d4
        d50559df-ac6f-4e53-a8b2-5e03766d7a0b
        7ad0d2db-b55e-4dca-899d-b498c0610256
        7b9585e6-4276-4dfe-9cdd-7512b0141b67
        7b9a788d-6c80-491e-bedc-968ddcaf2fd5
        7bdc8ca6-b9a9-45cb-a1c4-5e0a1f24ea4a
        7be245f1-4e89-4404-a5f6-4ee79a3a9ba8
        7db6e9ef-419a-4e93-b4b9-b587a37a2ee9
        7e64efac-a5e9-436b-8a68-1be1714496f9
        80be0c6e-4f89-434b-b27f-9c126d514ec8
        8348b6d6-fc52-4904-9ff1-466fe9ef9bdc
        835b7ec6-12fb-4ffb-b54e-dcc27f86b62d
        de5c8765-1f93-4409-83cc-f8893a06d0a4
        e4e45304-4231-4537-a860-806ce47fa9ab
        e728c74f-3245-46ae-bac2-9c58098371a4
        f18c9cde-d95f-4870-87a8-ffb5d1934236
        f9dd3c60-653f-460f-916a-92c977aafb42
        fbb7a30b-5f29-4876-a8ce-9e19f1f1123f
        fd31393b-45e2-49f6-85db-d13c5108f080
        fe62262e-e483-4cae-92e0-e793e0a30269
        fe82cc18-abde-4768-a21b-69d02a7ee866
        001a5744-699c-4900-b1c0-1a4c15b2cc4e
        01d97348-3528-4efe-96c7-5615593fbde5
        0314c41f-e948-4d55-9307-f6210568b0a7
        03803e80-3ae9-476c-9dd6-cef4747020de
        03e2894d-c257-423b-bf32-96a2c9e44b3a
        03f4d4db-f86a-45c1-a837-00d7423d99b5
        04cafa59-74a4-414a-83e8-418200316296
        04cc6928-ebce-4f79-a1b2-945ebaff5109
        055247b8-27a4-4899-87fc-3bc53292ee0c
        058455cd-eceb-4760-af09-ce52775fe963
        07a0bdb0-77e7-4093-9f13-b3a044c2c96a
        07d829ae-cb4a-437d-929a-9d50937b4728
        081213dd-12a0-4759-b7dd-d7b0ebb947fe
        08655283-46c6-4920-a670-427f1c9175d7
        0897a096-e077-46e1-8b5a-34329c3739ef
        25088e8b-67ec-4343-be99-1be926bc0394
        25541c8d-defc-41f0-b424-f847349f8220
        25f86ade-b421-4e76-b52a-e45007419b37
        27600945-1031-46fd-8a47-06702cdd56dc
        28baf843-6c08-4d7f-96e0-26c1ca87e986
        28ca1e1d-aa0a-4dd6-9f00-497993a6e7b0
        299f8d24-250d-4791-995e-5b39a2581ffd
        2a74b153-1e32-4a2d-a51c-0fe3161d5ff3
        2b1f2b87-1dea-4870-a749-d555e93e8584
        2b6ad327-0380-4632-a297-2b041564c7f9
        2c4e38b4-9260-491c-bac6-4c0a59a9df70
        2cf36b4f-484d-43de-8fc4-45e8352d6a0e
        09d0d5bc-aeb3-401d-b00e-ca721d29d470
        0a712e90-6c8f-4925-95b2-5e369a8071cf
        0bf5ce7c-c774-4ae1-bf87-0ae82215c931
        0c414346-fdec-4090-8a07-5d5c3c5079b3
        0cb68f24-7345-43f3-852a-d859f1b19c7b
        0cf1867f-338c-4177-9905-9300bf7decf1
        0f32cf0d-4746-4885-b24f-5c0e4b966d0b
        0f609d19-12cc-4212-9b9d-97c59bb1bbd9
        102e8462-c19c-4cd9-abdb-622a031b5193
        10455651-9c2d-48fc-a0e6-aff99a70791f
        109d209a-c1eb-4cf4-bbb2-523e6e4b9742
        124b4c4f-edb7-4346-8da5-a759499742b5
        124f076a-e502-43bd-9283-86a53fdb779f
        12a465e0-f9a9-4194-bc73-56078283a10c
        130c8297-0c82-46e2-831a-6c77dbc99d83
        1ce07778-42f3-45ba-bf7d-abf960e299c3
        1d1a185d-ca08-4eaa-8807-8884e61dc8b3
        1ded91fa-bba7-460d-a57d-c1b82d42b6c3
        1dfb033f-ae0a-430f-9c16-f2df0db0b004
        1e0fff89-ba88-479c-aec3-732f16c84712
        1e84025a-cacf-4c25-8c3d-bc70948a45b7
        1eeec665-97a3-4029-a879-7559f5b7edbc
        1f42f837-9ce1-44aa-9dda-49cc270ff4d5
        1f5f8ea2-17a4-464c-92fe-3c251062fe60
        1f7a19e4-3218-42fd-b311-f04a4cf821cf
        2023fefc-8207-42ee-95a0-239999b0b689
        2087cc52-cdf4-473f-bf5e-ee4047ed4af0
        20e9c98d-3aa6-4e7e-aed1-f25cc34a8dc7
        2114b1ff-d5b4-4491-95ee-c189e54036d4
        215d0299-0f33-4bd0-94e3-0479ff159c62
        216d43e9-0623-4d65-a30f-42e25ec0bfbb
        2305d206-f63c-4069-a9c6-a200a81ba86f
        231acefb-fb2f-4394-9a76-5e573126fd4d
        231c23e2-e48e-4e42-8f23-d5acee08ab24
        234a0541-ae3f-46e0-98d7-48e432eed7ad
        237b5d93-6575-4f55-8ea4-832b0009e64a
        24156fba-277c-46f6-aaae-5371fd54b325
        24196734-367a-44a9-b050-c86d9a134e33
        4b1183b6-06a1-4fad-a59f-a094bb0564e3
        4b2e4240-aec6-4d8c-9873-8637c9eaed7c
        4bfed6db-c355-4dcf-b11e-6cc57ff80906
        4d2710ce-ed31-4356-b771-9412aea89fc9
        4dcae741-f965-489e-9eaf-79f577c668a5
        4df809ef-474e-4b27-992c-c036f883ddf3
        4e145886-caf5-4aff-8ba9-08aebc997f9e
        4e2f9aca-6fac-45d9-bfca-3e29d278bdb3
        4e340b23-05f3-454f-8ea9-71baffd8036e
        4e4af7a159a1a087881678bb
        4e547aa9-bef3-4b1a-ae8a-fa38a87baf13
        4f34424b-995e-41c2-97b2-2f3edf257f11
        4f6baa6a-913e-4370-a68d-622cb8b0a4a1
        4f6df065-70b2-435c-a798-030d48c2c8ec
        4f997d60-7c1c-433a-8183-895064b29193
        50911354-e158-4345-92dc-f77d2d6ed461
        509aa4ab-9b8a-4f38-97e2-4c4eb29a05f4
        50e3c017-0dd8-490f-ad8e-10d504e06319
        51206e605acca2dd678e99ab
        5185708d-7417-4483-b11d-0f49fc595ec7
        51a0d605-ebd3-4045-ab53-2f4ada8515ec
        51c4ffe4-f377-4a96-931a-b2541bd5816f
        520ee8ad-fa67-4a3f-9bad-cd6ce8bc6801
        52664846b528abd147a434d1
        52f901d3-d481-4871-aa11-90e21b9028fe
        15e2ecf3-4941-462c-90b5-ea575816eaf3
        15f09154-bd34-4163-9dd3-4f5ab8f3594e
        16f93daf-4f31-4f0f-9cd5-f798c84e7b94
        1763dd55-9c24-4e03-9f30-a3ccd6f95c54
        17b95bc0-08ee-4664-bbe5-a21143482481
        1864aa31-3026-41ce-a092-1f2da3bf3a79
        5b859d78-0e78-4ce4-8d45-448c7dcfcd0c
        5b939261-d0fe-4f2c-a86b-8a419bca9554
        5bae8f2b-a9e4-4a5b-8e48-40dda29edad2
        5bb208cb-1e94-4a95-b667-9d1136863de0
        5c25a4cc-5cae-4b9a-8b05-e1b577889983
        5c2e1e79-4b21-44dd-b17a-583b49350785
        5d1d9da9-0cf2-4238-bbdd-73f33a78a084
        5d26ccef-8eac-4f16-a593-7b19a5fe0c55
        5dc81479-1fee-4128-a1a5-d2075c7febca
        5ddf5526-bd0e-4a65-a5e2-d8cc106db1db
        5e6103b8a472abe1a30f01ca
        5e8be5c1-1e2e-4ead-bb48-78cfa892a1e2
        5ed08b3c-08c7-4983-8509-1d4a4c79c0af
        5f534bac-e8e2-4c8e-90f3-d1c45d7f2174
        5f9b2bf0-c43d-4623-adc9-8d8a49345b07
        60673c83-8bbb-47db-9f29-bd159e0b8707
        608afdab-7b1a-4d78-827f-e2334e60052d
        609cedc0-1953-4aa7-a567-f8506098363d
        60fad93a-112d-4d70-8602-d33aa7861e4a
        60fb600c-dce8-473e-996e-a247ccaf834a
        60feafd0-dc3d-487f-88fb-8f7b055ae43c
        61170046-4f6d-490a-aefc-7bc60a5d0c44
        6153c76b-d778-48ac-a5b4-f207a1fd1d02
        61693eac998c7443847a0127
        61a1173f-c252-4235-bb74-8a6e49c47d92
        620adfc0-3676-4067-8441-ffd274a434e4
        621e42e8-49ee-4e4a-923b-c33958ce8c7a
        622f30e4-13f4-43db-8a70-9f9e77b7039f
        6336e810-78d2-4449-81d3-3ed9249eb942
        64385697-d91d-4571-aa33-80e77382908f
        646c7fe6-a364-4a8d-aa6b-6823ef72a8d4
        2e036683-c880-49ed-ad0f-26faac7b4f18
        307f177c-4a2c-489c-a0aa-61eea8dba557
        30b9709f-69ff-4539-84d2-175289c1f440
        31c115a1-17ef-4219-ac32-5b56aa672dfa
        31ec2fb0-055f-4480-8e07-1692b4d71b3f
        328aa2ec-96ae-42de-a1c8-2fbc1cc29950
        3345ec8a-31c7-4ded-9d5d-724371221a13
        338d870f-ad87-4e81-9e70-4c4d929cc35c
        339732f5-7915-4886-8350-add5fcb017ec
        359324f3-e056-442f-a35e-13f466a1ad99
        3621eee7-1e97-4201-bf5c-d18586a5add5
        36a6a4d8-99c4-4dc6-bb7a-510d2f909afb
        4193d7d1-6f45-4f87-b6ca-4775dc3ed2f3
        431b9d7b-85f3-46e7-a2c6-0b0a5094943c
        440ecc65-5a0c-4484-afa1-3d57b2fa9f3e
        44b92b9c-15fb-49aa-b46e-106ae625c094
        44fa79ec-856b-47b9-9bde-8d644f7313dd
        46899161-9a14-43e7-b734-9710beeb2b36
        481a589f-2e1c-4617-be53-0ad7b6d74fa5
        4933c824-b959-4f4f-80de-ba413d1b8250
        4a2dc61a-1b98-436c-9adf-3a5b617abe5b
        4afde0f8-a90f-417b-a19c-7d7c883e28fe
        b4714e63-0bbb-474a-bcad-fd30f981308a
        b5a48d12313081ff745bd299
        b64285fe-9bb1-44b9-b38b-2c749028cad2
        b673112f-7d69-4c00-90d8-956f62ea8b0b
        b76d26c0-88c3-41dd-9216-18dd3a995a96
        b800c244-8218-49f1-b61a-6c3ceff85262
        b860b738-0e53-495d-8d2b-c93583c1efe3
        b873a793-08c6-4280-a676-ceb2367fe2dc
        b981a9b4-ce9f-4563-9555-e289bee956fc
        bab11da7-a293-408d-a3b4-33da70332ee9
        bacaf3d9-8b95-459b-88b3-b67b1902d533
        baf50566-a786-4a46-8f24-c776b724901b
        bbeb3345-ebb9-4e81-9d99-bbca4fabe331
        bc0fe5e1-01b7-4255-9460-7526fe836b09
        bd1d32c5-9a0d-4507-b27a-e719790eb3d0
        bd7e01a5-9668-4cf2-8859-b1637a7f9c1d
        bd9f32da-2fe3-4dac-8454-1efafe3efeec
        be054b4b-589a-4dda-a1f6-d3fa08d42ab4
        be087f50-aa2e-4e8b-8795-6f3befacc07a
        be75c4ec-01fd-466a-81ba-a27b88e478d1
        be86ec6f-9d34-4e08-91f4-e971452984e5
        be9772c7-5e44-4180-8012-6911579cd4ad
        bed643d0-2525-4beb-a952-ae8626774bc0
        c086cc802637400930ebb449
        a07874b9-a1bb-4533-9c14-4384acc050e9
        a07cac86-ccc6-4dfc-848c-f6e1f2eb85c6
        a164314e-e527-4cd7-afe2-5abccfe905eb
        a172fcf4-0729-4b4a-bbfb-ae3581779ccc
        a19e2bb2-7c6c-4dbe-8b9b-5faca489f1cf
        a1f1cdb5-4aae-4de7-abfb-3ff83f649a8d
        a23a2bc3-3400-46c2-a4b3-334aa41379bb
        a27c785f-59f6-49ee-a87c-d0ea634ef686
        a2c7ca72-eeaa-4ec5-82f7-d3b9646b75e8
        a4069944-ac19-4a40-9e31-258af4b50cb0
        a4caf0e5-95cf-43a0-b26c-6116e8c79461
        a4d215cd-a353-471f-8e79-cd420e7d5e1d
        a4d8f861-19b5-4bc6-8797-369646fa8bae
        a56a06fb-462a-43f6-9f64-e8ea9d7c723d
        a591334a342e13dc00b4d42a
        a6be2245-7001-4377-a40b-ba195d6dd664
        a6d39cdc-ecfa-4957-9160-061bd212aee5
        a6fb0a37-2053-4097-a047-8c6320d62c03
        a712f9de-f021-4a5a-9ece-f2857a6ebd2c
        a73dc353-3ef9-432e-803b-f1482e075a9f
        a76f1fff-7a1f-4144-96b8-4f1cd03e3b31
        a7971da2-7396-4cad-bd09-0bcbc470a967
        a7f2156f-bbd4-4ab4-a773-68282ab46883
        a9143085-4978-4083-91f2-3b13007f9816
        a9271f32-6a24-4bb3-817e-fd9abdbd0050
        a92b597b-66cd-4dd2-a039-5194d53093fb
        c086fd4d-a274-4d87-9e0d-9a8fe7785cae
        c0a29175-c644-4891-bfe5-feb6ee95dcf9
        c11f5187-8fe1-47dd-abd3-81b6533e9e71
        c13a5bfe-974a-49b1-bef4-613310fbb4ca
        c20042c3-a871-424d-8aef-0111bcfb30a6
        c29d0ee8-e18d-487f-ab9a-494203cb86a3
        c2a24bbf-b849-4223-b7b2-7be6b39ca19e
        c330221d-33e4-45e0-92f6-e328f21aac8d
        c3995b50-acdc-4a62-a986-4dc7f75c1851
        c39c6ef3-c28b-4311-a924-fe703434e902
        c39f7814-d3f1-4bc4-911d-56052ba008a2
        c3d19641-283d-4be9-9cb7-d6e4ca1a2cd5
        c41f3c19-1358-48cf-bbc9-06c5c2797953
        c43046f1-5652-4db7-8829-c02b05a1a793
        c4c19975-a49b-4e0a-9b6a-1bbcc5f703e2
        c5149972-4c05-45b6-ad3b-876dbf29e924
        c52e97fe-eec2-424b-bfd7-8c6d71247eb8
        c5e4e5e0-c602-45f0-b77b-4e6146ffac66
        c6514b51-2eb7-4f53-ae02-6c7046ef651f
        c6ded083-cee1-478c-9fd3-e6b64053fc8e
        c73837a9-6e90-4f7a-bcd8-8c019411cd9b
        c75144c0-313f-4c7b-b104-57f59b8cc91f
        c796476a-2f1e-44df-aa5f-3676f82d30cb
        c90716d9-58a4-4471-92bc-c234e0a6d146
        c9e42280-71e6-479a-9cd7-2b079cab4dc2
        95d3c314-e18c-45e7-b1f7-4fd8d8f76003
        95e0eac3-95e5-458f-8bf0-1f557e399475
        95e821ec-bf76-45ed-81c2-d4597790bdd7
        9783d0ac-0352-467b-a895-34ff1218a2df
        9858bb61-e9e7-427a-9017-2c9dc51e2c58
        990e1775-546e-4839-b163-dbaebbae0df4
        9a57f691-a12a-4feb-9e06-6e8b51651fc0
        9bc394f2-211a-46c9-a86d-59333eb8de74
        9be85755-5f3f-49c7-8e58-ac70ff84a8ba
        9c37ddc4-9f71-4627-bebc-a0f01de74d5d
        9d286250-ccbc-4382-8020-cedf6216c4f3
        9d344bf0-9a17-4ba6-a259-4a788ae9ea6c
        9da23734-cc8f-4cd3-8ab3-cfdfda872e5a
        9e48dd8d-c03f-4a93-94e2-12d780211e8f
        9e629d36-7175-491d-b0cd-1d29904999aa
        9ed0d0a8-fb2e-4f1d-8464-5c88a769afbc
        9ef4673c-2e5e-4e54-aa9b-b32a0993db98
        9f3625e6-37b5-410e-a0bd-f091899a5c22
        9f4d83ad-4aca-4549-ac96-43a2e3dc21fa
        9f549bac-698f-4ebc-a5e8-009bc882aac3
        9f649fa0-16c8-46cc-ad9b-b1062178a865
        a0018e12-60d1-430b-8ce2-aca68e5a561c
        64823747-a1ce-4de3-9773-b7805f4108f8
        6534cf6b-d4db-422a-9dd9-45188d0c7f13
        65e1207c-f5c5-4292-8957-61653c9b03dc
        663ea8ed-4ae2-4c41-93f3-9c6d2c39672f
        66a08715-8753-4372-9b85-8c80a832c1ee
        66f40ec5-25c2-4132-a14d-9176e2fdb63b
        6701fdc4-8be5-4845-baa9-f76247c6e296
        673d718b-6915-407c-bfa5-4d72e7185580
        67402346cbdaaefe8c4046a4
        6767a3c8-ffda-40f6-8fd4-f488cfeedaeb
        676a6d52-ce9a-430e-8f8f-5622bd5a2bf0
        67f11741-279e-4b88-843c-c49e9cf5779d
        6875163c-0504-43c6-97b4-8681385176b4
        68fd26c7-f45f-45d5-89e5-ab78945c534e
        6a22a1dd-e468-4c5a-b98c-5fc951477e1a
        6a5548cf-8ba8-46b9-8a40-3b5899f3052e
        6a573092-4ad5-4f35-b1fb-1492b4706c8d
        6a684dbc-15f6-44e7-b319-7a105d1230d0
        6aa53658-aa56-4688-8dca-7143b9e7bd91
        6ad41de1-02ec-44e6-8204-6a697e1a0b8a
        6b30bf56-588c-4186-9b75-00c89a99922c
        6b46640e-03f2-4ee6-aae9-66ecad7f4a3c
        6b85df28-8d87-4a70-8443-8a568e5eb023
        6be02afc-0126-46ec-a241-28b964521397
        6be26876-23fd-44b8-b29f-d0647ff907bd
        6be36877-edfd-4719-a0c9-232526b55016
        6d0ad2e2-c736-4985-91ee-9d1345eaa1e4
        6dedae31-5695-49ed-be68-455cf772ff01
        6e3399ba-b77e-4bb4-89ae-11258cd3f3c7
        6e35b4ca-efe7-4727-85bd-ec694b261171
        6e5cfc57-af17-40cd-9a88-af450a2d7f39
        a9962c70-ee7b-4efb-9340-20c527cc7c97
        a9e711ee3f688b78a2b652bc
        a9f55b03-9358-4328-8469-1aceee21762b
        aa2246f6-1f85-4385-8b69-7f7658170f54
        aa3cf207-98e6-4a36-aca7-57a20b46ce9a
        aa93fc67-00d9-4c6f-997d-e096f84527de
        aaa40bdb-5e2d-4b17-b813-8874af7957d8
        aaa9fec2-cd1d-4462-adb7-b98608dd50a0
        aacab6cd-a08a-4954-be06-d658f4f4f7c5
        ab1f1d95-d355-4ebc-9794-d778dd8d4e06
        ab24ba1a-2cf2-489d-823a-3589be2ee417
        abe8c0fb-ed43-430c-b66f-0f01311219da
        ac33ecd4-0d91-41d8-a7b4-77381f1370ea
        acca6a8e-cd89-4d4d-94ca-d5a4d953b217
        acfa5029-ad1f-4e64-92d5-b68504292b8e
        ad63ce7f-7e1f-4e68-bb02-002dfdfbc501
        aeadb3692e1c50e0c0244993
        aee065fe-3e3d-4b8a-9fa7-5c00b2103735
        af47b36c-8b86-42e1-a974-4f5f9cffa9c0
        afb27d17-977d-4ed0-853d-85c757ccd920
        b059598a-ae5b-4475-9d05-e4b8736366d3
        b0723219f2b29b16d1e065ca
        b0bff27e-1c06-4ee0-b42f-4c25e7ea6397
        b11acbc1-3efe-46c6-ab6c-a72f8f22dcaa
        b11f5427-608a-4e50-8c98-9be0179d44ae
        b1b5e777-9343-4b58-86d7-582dc6e05726
        b21af05e-131d-4f79-a97a-263567e90ef3
        b2cdbdfc-9e0d-4323-bbf0-6992f2cb14d0
        b36c2d00-f121-46bb-99fd-fca03cc6a1c9
        b3aa97ff-77f0-4671-9546-bee5596f0283
        b3cf6686-558f-4da3-ac0e-6916db5d2c74
        b3d88aaf-7e9d-459f-a409-656ce8489d69
        fc4f2006-6f91-4b1c-a1fd-a73971eac668
        fcac209b-db41-4c21-bcfb-9f711baefd77
        fd3d205e-803b-4fa6-af2b-fc7db106d220
        fdace325-1ca4-49bc-95ee-8c061b4c6e6b
        fdef859d-e0c4-449a-bcf2-55675f310d14
        fe321744-d971-469c-8657-cd89ec3f2e6f
        ff269e01dac689d10b99d597
        ff26a27e-e39d-4a4a-87e5-ec832bd4c13b
        ffbfb5fc-1453-4f2a-81ca-bf99e3aac592
        ffe09146-ec73-4ea1-86a1-06301a473a88
        de41f82c-3a8f-4ca7-a50d-eb6addbf2082
        de675946-cb83-4889-a38c-995839c1f36e
        dec084da-da08-4eea-b961-d5158568b31a
        e054346f-384e-4276-a028-4752729480a5
        e0aed5ba-e48e-4b0e-81e9-f672921e490a
        e134c471-15f7-415b-a6da-e9b94638c533
        e15a199a-617c-4f53-b66d-f81dfd6164bf
        e1d8b15c-7534-4979-b0f2-3dd8cce42581
        e233ae03-0b2b-4280-9a18-7f4233da3e47
        e343fac7-8f6a-4a6c-bb69-8309399c46c8
        e359d5e9-7283-427a-909e-4dc3ac3fe3d0
        e38e26ce-3493-4496-ab3c-4fd09ce07d6f
        e4220833-ded1-412e-a4e6-0e00250aa0eb
        e43576ac-4854-430d-bc84-fbadf47fcff0
        e47eaefe-92ce-43d1-b3e3-93b3c45989ce
        e481ca22-f75a-408f-a9ae-064a75d5ba60
        e4ebb6a4-59a5-49f7-9c58-6a9a12a41051
        e4f914d2-e5dd-4e3d-a04e-e8fd96a26275
        e5d7ee98-03d6-4caf-bd88-475316250d76
        e5e65fe1-6a59-49f9-b6a6-7ca3317459ff
        e6095e41-77bd-4d6b-af9f-9c64f34fc3c0
        e61bb06d-349c-4578-85a5-0313c43d1c39
        e654fe87-9cd0-4385-a75d-36ffb92c7e9e
        e6bd1e17-41e3-4786-ba15-254692913d80
        e6e3931b-7214-4bfe-889e-ad55a9d53cae
        e7252157-4e42-41c9-becd-4340af7d8474
        e74cfbce-623d-4f5b-8111-b6162611e48c
        f23f2f0a-69fa-4963-84e5-29f4874d44c6
        f2b5c34c-75ed-4f08-aeaf-0a025bf1340d
        f2d82828-60f8-4823-b976-1d613cb1d6df
        f35d06dc-d9b2-42db-8bbb-f6bfdd05dc9c
        f38d7df2-74e9-4e4d-889c-bc84de11efcc
        f3bea29c-3313-45ed-8d52-bfa05f0d8680
        f40a2855-d2a3-4891-a951-e4388c4895f4
        f4685cbb-045f-40ac-a2d8-8d0274362155
        f4950c7a-85e1-46cc-a992-7e6912bb1fd3
        f4b3e566-b5d4-4c9d-93c3-e93f41231157
        f4e18bd2-974d-4b41-96b5-5e2b43d9995f
        f5d93e84-dfd1-44f6-8b6f-c5b1f2bd6ffe
        f603181f-e8fb-426a-9fed-85afd6026a67
        f6ccb12f-50cd-4460-ac9b-373920f0c92a
        f6e13365-80f4-4750-a099-cd2620eb83b0
        f6f9b768-42e4-403f-9351-50c416907aca
        f74e1ca9-cf22-4fac-bc0f-fa92627aed8d
        f75c4231-0432-492e-a41b-f83aa5bb5662
        f7961da3-857b-4c17-99c7-0871e75a6b80
        f8da6bcb-01cd-4fa8-aa01-9f0717ad4fed
        f94cbc40-ba41-4556-854b-a642f0fcb9bb
        f9ab4f2f-9c3b-41a2-b4c6-1f08b2aeaeb6
        fa8bf289-da68-42bf-b4aa-0fc6a220f0fa
        fab4edab-ec3b-4186-bda5-5e39fc88d236
        fba5d103-45f6-47be-92df-823327835e89
        fbc744c0-919d-4868-a9b5-1b3397aab259
        fc2940af-c8a0-407a-b735-cc69d2d392f7
        fc4701c9-ad71-4fc9-997d-5239432525b4
        e82a7c2e-1f13-460a-a56b-076690bd469f
        e85cf199-69c6-4ada-877f-1e9359a916a9
        e8dc9055-1189-4a97-a19f-4ba96cd9dbc9
        e98e99b6-83c8-433b-b29f-b6e5d4726f36
        e9ce6c08-268b-4c7f-ae8c-f2fae13ca676
        e9eda61b-8ec5-43fd-9d4f-c42d244b5ca8
        eb23578b-efee-4c8d-9699-aa1f74b3b20b
        eb719781-85cc-4539-94b5-5b9cc75a705c
        eba59d35-42b4-4748-b579-44c1ba560cba
        ebaf9c32-0716-4531-b289-033fb8667b99
        ec116bdd-6c1b-4626-9603-868bc0d37547
        ed52cfc1-bde6-4d11-a2bb-5553a8d8cb17
        edf0fb7b-2f78-40a2-b20a-5acd5396b4a7
        edf1d6b4-4f84-4564-8e8c-d660023f818e
        ee20ba5d-1687-4b08-9747-86b149b929ad
        ee3eaf33-4fc2-495d-bf97-51eb5aacf3c8
        ee5e0dd6-09ae-4b04-b0cc-ef5208bc4af1
        eed11a0c-8337-4cd3-b0f1-8b859949be33
        ef0d777c-c546-49dd-92a7-f04d56f70dda
        ef26cba2-4b99-4494-b194-59465ca48042
        f081548c-55fd-4b99-8759-2681b5ea10a9
        f0b45981-6f45-48c5-a482-4b32b1afc80b
        f0c736c4-3042-4b59-ba18-e1e7c466b99c
        d5c7d9f1-4056-4f15-b92d-28891ffbf763
        d5e20df6-c92c-4870-9e7a-0b6df6fa73a7
        d68e489c-2b13-429e-87da-6dbf77606d9c
        d7669f18-cb96-4411-ac6b-3b8682f85dfb
        d97d238e-b522-461d-8ec4-b1047953cbcb
        d9c37877-f121-45ac-8343-84561fe8c23a
        d9d21b90-433b-4e9c-b8fa-70fc8cdc7fe1
        d9d3c373-8be5-4b03-ba82-616cb91c805a
        d9f32771-f80c-4889-aa29-278c0f617edc
        da1e7cbc-9f38-48af-b721-041e52c58cf4
        db0ca45d-ebfa-4d1c-92c4-385580912565
        db8425a6-7ad7-42a9-a4e4-b7d225bb51df
        dcb5b446-b18e-42a6-a7d4-ba0c3ea2335c
        ddb5c14f-05f6-42af-910a-73e85b75b652
        de39badf-8081-4498-bb23-bcb1f6b8ea79
        38d61254-0b53-4257-8efa-2d5e35e68006
        3956cd7a-da0e-4f96-8662-e63c912993cf
        3985adad-7f68-4ad2-859a-f26082d689db
        39b2fdf6-3704-457f-a94c-fc265f5ce9dd
        3a29d1ee-4beb-4919-831c-9b454ed11db0
        3bd2c634-5620-44be-9765-29aac0247e28
        3d51e17c-b2e5-4bca-b9ec-e939a3e4371f
        3dea2113-2a09-422d-9fc7-2138b047f52b
        3ead4c0f-5c71-4cff-8cb6-4da4f633ef4f
        3ee22b89-aec8-4d7f-b5ec-15308b3c2dce
        3f8b3973-246f-4d6a-94bc-a0bff6f89802
        3ffac938-56ce-4c32-ba11-bcb893474978
        cb494058-c8b8-4ba1-aa80-1ae829f57f6f
        cc106049-d3c4-4c09-bcec-d239183e66b7
        ccb68890-79cd-4c92-8067-b4659fe49e12
        cd31d82f-10eb-45c5-ba24-ec3a981dd38b
        cd4c1ab1-c93c-4333-9696-268bf7335348
        cdf1e542-31e0-42cc-b0fa-871b1d47fe39
        ce231e60-30ab-4fc1-af6d-1d61ed48d7cf
        cf4685a8-73fd-41a8-92ea-f1a50d27b839
        cf57ec77-d264-4d3a-b809-ac7f93f17e92
        d043e35b-c3c4-49e2-863f-79ed80a08efd
        d19039f6-7371-4d11-8fa8-26f6d4c765d7
        d1b9b97c-1b2e-40d3-83b4-722f30aa91cb
        d29f3190-3f5e-47d4-aaf8-1302f2fbae67
        d2e2de38-cd6d-455d-b6d4-348ac556c53f
        d344cec2-d14d-45ab-aa4d-8f29b298242d
        d381b0b8-6553-4600-81ea-f8a888e2800d
        d405d80e-f0da-444c-8e29-20a6ed96ff97
        d415ee64-6e81-4154-9b42-b78c1092fde9
        d41bf57f-9ca5-412d-a18f-bd7ced9e827a
        0c5e0063-69ff-4354-bfba-613916f6e361
        0dc9dc41-2b4c-404b-83ec-97e214dbbd9b
        0e05cc23-6321-4926-aaa6-1866b4543ddd
        0ec3541a-a1da-423e-82ab-6f037ba00a92
        10238164-7b34-4525-b845-680dfd79b7a8
        10a0adc3-e864-417d-93b4-d41abd093fc0
        1152ff2a-17c5-476a-b6a4-7e848a6e275b
        115ac6fd-f237-4cea-b409-0887a4c732c2
        124e6ed8-a195-4c53-b3f7-64052f11b8dc
        12d47753-7c8d-4b0e-ac74-f83bfc18dd5a
        12da2e17-5e00-4974-ab67-34765068e622
        136efa2a-ca17-49d7-af09-d94a82578299
        13e8ade0-b689-4ec4-be0b-7b1943cb5cac
        13fa7983-6e9b-4827-8a52-b28f0f6dfe46
        140b777c-9f14-4c41-a6fc-cc1b19ceec02
        160b34d9-5cec-402d-afb1-ab4c257b93df
        168d35ba-542d-478d-927b-8007f8512cba
        179f52bc-efea-4b3a-9f50-2c8d64bd5303
        18a7b0e3-ee3a-44f1-a05c-bd174ed930e8
        18e4fcfa-9114-4044-876e-dac9b3b51cef
        1b2b43a0-e9e8-4227-b98a-22bb341c8895
        1c6b670a-ef20-43dc-8d96-c0df6badd3b3
        1c7c8f23-64e4-4fdd-bbcd-8746ac6b17a7
        1cf58544-a986-456c-a769-be6c8ea98eac
        1d44e1cd-f8fd-4d34-85b5-d3ee3cbbc1a6
        1dec6451-6fbe-4a15-a9a4-2212727802bb
        1e0176f0-472c-436f-ac81-7ad887e667b0
        1eaab419-558c-4a6c-bd10-3418232feacc
        1fd2892b-0506-4833-9059-999040b7f50c
        01cb277c-9f51-4655-b084-80847b6f0fc2
        026350f0-94da-4172-b180-41ae077a6af4
        029abd55-bde7-49c3-b9d1-1b73952be41d
        036eaf42-54f4-4f17-bf34-cfed2e257bbf
        03a3419e-484f-4a99-a1bf-0e7a80a8fa47
        03dba7dc-01c2-4abd-ae75-027f74f0cbd9
        054978ce-2098-41fc-bfac-85fcdb20c27b
        0661e243-2727-48f6-a6ab-cd250c23fa6d
        06bd8d02-411d-46d7-8024-94672661a758
        07e2c3c4-f478-4782-9c0a-51e6b4aed11c
        0a0fd13b-01a3-488c-a347-dc512b16a677
        b746c5f8-e49f-45b9-8644-07bc1c1c07c0
        bc3563c1-1fc8-4643-a754-98c91775ffd0
        c72288cf-25de-4e62-90fa-90c4dd9df124
        c83b605c-e4be-49b3-8191-c9f426f41dcb
        e1dd0414-d9ff-4e2c-a004-d90a407852e3
        e5527663-b751-4a77-9e9c-1a5ff9d27ac1
        e60830ab-d169-4f09-a373-c79ae45136f2
        ec92a782-1404-4aa4-85b3-a403698a22f4
        f61635fa-1cf3-441f-aa73-e42c776bbeaf
        f769b2bc-1ed7-447c-a5d4-542ea70aac8f
        fc3ecb9a-889b-4f90-961a-553905ed5ad9
        61e4a797-3168-49b4-ac9c-535b02edf1e4
        621b6ae2-5616-47af-a324-875d2c29b763
        64f0966b-072e-4c0b-92ac-b12713f4278e
        652810fb-f8a4-46f9-a2ae-40828e1af041
        65be3525-4565-4281-bfec-24a0725e1b62
        660a2c79-6b8f-483a-9822-f2441791e065
        6706b13a-2829-409c-9fcc-3be435d96b93
        673ce101-9753-488c-b657-23754de9facc
        676a9f65-aa80-4226-abbf-3382bf50151c
        67925af1-df23-45cb-8511-7fc89dd0bc1d
        67defaa4-0d9c-4de9-9aed-719a4a6234e7
        688b595c-bfbe-4386-bee0-373de6ebd4e1
        69eb13c6-71ff-47a8-aa31-ef13b776e765
        538ad452-1e48-4ff5-8fc4-d10b71ae6161
        53d69218-c5ae-4e05-b3f4-ba73a8f20002
        5428b931-534f-490e-a599-ada4c32e18f5
        542c0541-6561-4f8a-8261-2557c8f8deb6
        5547ac5d-a6ba-43dc-a094-079823b574be
        55d27159-d8ca-4595-9ba5-ae9a683e24a8
        58521975-ff45-4e3b-9246-fed5ecd6eec4
        58b54374-3c8d-42cc-a0a1-598ecea40457
        591c5c5e-d2a7-4148-8804-8c167f392ad7
        59543101-b67a-484e-a2f8-9e9d9bf51cb8
        59693a18-09cb-46e5-9f69-fe3c48a86e6c
        599f4e6f-4739-4b40-83d4-14288b989518
        59ef87fb-f8c7-4d51-bc50-23e7282697f4
        5a54bd5f-4dfc-442f-84fa-2ffac28a9363
        5a6ce965-7ef9-492b-a8f3-dc174a831b74
        5a8e8aaa-d9c3-4132-9485-6bacb293f7ee
        40bbe51f-7db0-4da0-8ca4-f93b90c8099d
        40cca804-4227-4065-910b-d37f4047b30b
        40db06fc-a011-4a58-82e6-5c02c284be6b
        40e48423-1fa4-4518-8dfc-c6c888d409d7
        41f4a3b2-f575-4bc3-9802-0c84aced1024
        425973c2-19e5-4a07-b2cb-8cc12ce60789
        4271f68f-f0ac-402e-8a9a-6caa3c4ce81e
        427f8f3b-1595-4dd9-9054-c65a9444c773
        42ba34ba-573c-49e8-9496-5575e2d50d50
        42c0d51a-596d-437a-b1c1-3472e7bf4765
        45ebfae5-73c6-40ab-8d64-730d2b1825fd
        47c76f46-d5ee-4709-819e-d75c8f6b8bd8
        47fc7642-5314-4bfd-aece-f8ad79c256fd
        49441abf-6961-44c6-9aa8-169748d6f7db
        498ee3af-11da-4235-a47c-d937daad9077
        4a5c7756-69e6-4c7a-8b69-0680256997fb
        95371d21-b040-4920-b1ec-002ce19e658a
        96297966-b271-4521-b449-82795fcf5e4d
        96a0874f-5485-4b7a-b81d-2c16273696be
        973271fd-72b9-4a53-9a9b-e8351a004d4f
        9749f174-b669-44e2-b41b-61e008cc0847
        97caca02-a797-4caa-86eb-1741086cf7f8
        9870a828-90b4-4726-87fd-66b0592da217
        991bdc16-7195-4aa4-a6c8-c4dba5dae779
        9abeace5-09b2-41bb-8c4b-96a0972708db
        9bc3927f-4587-4207-8794-e85bf160f5e6
        9bf85ab5-f413-4f1e-821d-713098c470d2
        9c1d59ac-3b1a-4cdd-b9c7-e5b719b45e83
        9c2ba834-a449-49d9-9e71-a92e4efcb653
        9c5739c5-18b4-47b9-bdd7-5129d42b91d7
        2a6fbf55-a281-41d8-a7a0-8e0ccb152a45
        2a92ccc6-ef1a-4ac2-85de-e137dea1c58e
        2abe4bab-a157-42d4-abc8-f017a196aa6a
        2ad947d3-68a6-4b83-9f47-d66dea47f44b
        2d6426c9-d760-4ea7-b931-94a027c0f38b
        2d6eefad-aa19-48df-8898-9c2cd84f89ab
        2dd81609-e324-4f56-a838-cec7af545905
        2ef5e6df-0468-450f-aafd-b6a08b191c71
        30c5687c-9e08-4746-ab03-8eca3894ee72
        313fdc35-64af-4ab1-99f4-178e118a07e6
        32105d1a-90be-42c5-865d-5208afe75db6
        33789038792f411caf9382d6
        33d2cd2d-62b5-4da9-8ec1-01bfc8a15ce1
        0b89dfbb-f1ca-4601-9d93-e155e86cc825
        0bf06e75-d65d-4eb7-b6cc-45315f0954fe
        0d108d55-df34-4f2d-a3b9-9002cb584aa7
        0d1ee253-df20-446e-88dc-a096c9ce7591
        0e59a305-621a-4cdb-8cdf-39f27b7ac3b3
        0ea32c4b-2b98-49d2-8f54-408d45b2bca5
        108b4795-32f3-49ab-9d2a-ac259bd197d9
        1090c8ba-bfaa-41dd-ba2b-581e053ac55c
        10a3f424-b3d9-48b6-8b13-88bef6dc0495
        10d4e1e1-36f6-4bf8-bd3d-0477afc36087
        117c41c2-3a07-444d-b897-78735616ff31
        124bee14-b2c0-4520-bdd4-4e093f23f91b
        61551d56-171d-4242-902a-a4301e81bc53
        61eba34f-29f7-4f78-8112-fd66fc164bb3
        710fd725-cabf-47e0-ad33-41d46b4938d5
        779c7749-aec6-4744-bac0-39c9be485332
        7d7103be-335c-4a41-9db1-35970100b485
        8fe20bfd-d5c7-4e14-b5a9-072d9e4e13cc
        9320c3a0-478d-42c2-95ff-e9da0af2f647
        93a32a7e-abea-4854-abf2-71c6493dd318
        9a8b172d-a131-4c43-9693-3128868a02d9
        a1c25956-f349-4ff1-b6c2-67407fe227da
        a72951fc-2fb7-43c0-88b2-fa348b60e5da
        77ce8301-c475-41e8-b27a-493479838446
        7877f15f-0882-418d-bec8-49e3c191cf58
        78c2f1cc-6cf9-4880-b24f-ff518e845b7e
        796b9d65-8946-49d4-89a4-16f0c4ac6c37
        7a148f49-d468-4888-a1f2-6ec3630868b9
        7ab76311-53c7-4fdc-a5d3-a613b3184e07
        7e00b0b5-4b31-4ec7-bb86-91f3b9973157
        7e2e3d8a-eab1-413a-a446-0f6558ae2835
        7ef52663-0620-4132-9730-3ad9f8d4ced0
        7f3d9016-a252-4855-abca-9c3f4b6b832b
        7fc3eecb-0177-465a-a96a-243699e2e299
        80ecfc81-bbb2-4baa-9152-ddee94fe7e22
        8160c98e-d0d1-4955-ace1-5f74b4dadc09
        81bc8222-5d9d-400d-83bc-fe15a7a366cc
        82021495-74e4-42cf-9d7f-7a17b76083e2
        4bf296a4-e77a-4d55-8215-a376476cfdcf
        4c9653f3-ebbc-4cd9-8096-a83d6c85efdf
        4ca054b6-89fd-48f6-a931-fdf5b00e5507
        4ccdf245-f406-4187-b0fc-e9071d53538f
        4d0ab682-5b71-499f-b729-149d60595063
        4d6e9bbe-839c-4db7-b76e-b4b0cbb5ac4c
        4f2ed557-bd06-4b00-9585-41073796ea36
        4fb2a023-c381-407f-b0cd-688ca8433291
        4fed1d2d-d9dd-4f64-8af4-03acecd8d180
        515b4816-1490-4258-bf5f-be1f82d6493f
        516fccc0-a5fb-4eae-ab3d-9ff3de2fb875
        52b6ffc9-e0e6-4507-b8bf-334cb5430162
        52f208be-a303-4a0d-910f-d3d42dcd49cb
        53257d1f-4051-4ede-a93f-ed8b3e9bcbbb
        54edd6f3-92d0-47f6-8c53-684e7ebd1e1f
        557d5a9d-e2ef-4654-b513-8583eedb1e3d
        57e5c49f-bdf8-4dc0-98c4-03173fdf77fb
        598df730-e649-4210-a74f-8f317ea62fff
        5c63a30b-6139-4ca4-a456-89d8c303998f
        5d8fc51a-1b16-4a18-9fda-294d7f438c3c
        5f17b6f1-9bc0-4649-a555-f205f555fa1a
        5fe237d3-422d-48c7-93a7-0c7496e3f9bf
        60fe2a3d-3638-48b1-9755-709e58bcf89d
      ]

      putarray = lambda do |array| # compact so that it's easier to work with when ssh/ssming
        puts array.join('|')
      end

      not_found = []
      update_failed = []

      update = lambda do |uuid, status|
        submission = VBADocuments::UploadSubmission.find_by guid: uuid

        unless submission
          not_found << uuid
          return
        end

        return if submission.update(status: status)

        update_failed << uuid
      end

      submissions_that_are_processing_in_cm_portal.each { |uuid| update.call(uuid, 'vbms') }

      unless not_found.empty?
        puts 'these were not found:'
        putarray.call(not_found)
        puts
      end

      unless update_failed.empty?
        puts 'updating these failed:'
        putarray.call(update_failed)
        puts
      end

      abort unless not_found.empty? && update_failed.empty?
    end
  end
end
# rubocop:enable Metrics/BlockLength
