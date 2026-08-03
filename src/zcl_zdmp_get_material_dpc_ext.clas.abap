class ZCL_ZDMP_GET_MATERIAL_DPC_EXT definition
  public
  inheriting from ZCL_ZDMP_GET_MATERIAL_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_MATERIAL_DPC_EXT IMPLEMENTATION.


   METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

     DATA: it_plant    TYPE zcl_zdmp_get_material_mpc_ext=>tt_ent_plant,
           it_material TYPE zcl_zdmp_get_material_mpc_ext=>tt_ent_material,
           it_volume   TYPE zcl_zdmp_get_material_mpc_ext=>tt_ent_volume,
           it_user     TYPE zcl_zdmp_get_material_mpc_ext=>tt_ent_user.

     CASE iv_action_name.
       WHEN 'FImp_Plant' OR 'FImp_Material' OR 'FImp_Volume'.
         DATA(lv_werks) = VALUE #( it_parameter[ name = 'Plant' ]-value OPTIONAL ).

         IF lv_werks IS NOT INITIAL.
           CASE iv_action_name.
             WHEN 'FImp_Plant'.
               SELECT werks, name1 INTO TABLE @it_plant
                 FROM t001w WHERE werks = @lv_werks.

               CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                 EXPORTING
                   is_data = it_plant
                 CHANGING
                   cr_data = er_data.

             WHEN 'FImp_Material'.
               SELECT a~werks, a~matnr, b~maktx, a~fevor INTO TABLE @it_material
                 FROM marc AS a INNER JOIN makt AS b ON b~matnr = a~matnr AND
                                                        b~spras = @sy-langu
                                INNER JOIN mara AS c ON c~matnr = a~matnr AND
                                                        c~mtart IN ('ZPHA','ZSFG')
                 WHERE werks = @lv_werks
                   AND a~lvorm = @space.

               CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                 EXPORTING
                   is_data = it_material
                 CHANGING
                   cr_data = er_data.

             WHEN 'FImp_Volume'.
               SELECT * INTO TABLE @DATA(lt_zdmpppdt002)
                 FROM zdmpppdt002 WHERE werks = @lv_werks.
               LOOP AT lt_zdmpppdt002 INTO DATA(ls_zdmpppdt002).
                 APPEND INITIAL LINE TO it_volume ASSIGNING FIELD-SYMBOL(<fs_volume>).
                 MOVE-CORRESPONDING ls_zdmpppdt002 TO <fs_volume>.
               ENDLOOP.

               CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
                 EXPORTING
                   is_data = it_volume
                 CHANGING
                   cr_data = er_data.
           ENDCASE.
         ENDIF.

       WHEN 'FImp_User'.
         DATA(lv_nrp) = VALUE #( it_parameter[ name = 'Nrp' ]-value OPTIONAL ).
         DATA(lv_title) = VALUE #( it_parameter[ name = 'Title' ]-value OPTIONAL ).

         SELECT znrp, ztitle, werks INTO TABLE @it_user
           FROM zdmpppdt001 WHERE znrp = @lv_nrp
                              AND ztitle = @lv_title.

         CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
           EXPORTING
             is_data = it_user
           CHANGING
             cr_data = er_data.

       WHEN OTHERS.
     ENDCASE.
   ENDMETHOD.
ENDCLASS.
