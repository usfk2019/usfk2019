$PBExportHeader$b1w_reg_trouble_categoryb_v20.srw
$PBExportComments$[chooys] 민원유형 중분류등록
forward
global type b1w_reg_trouble_categoryb_v20 from w_a_reg_m
end type
end forward

global type b1w_reg_trouble_categoryb_v20 from w_a_reg_m
integer width = 2811
integer height = 1996
end type
global b1w_reg_trouble_categoryb_v20 b1w_reg_trouble_categoryb_v20

on b1w_reg_trouble_categoryb_v20.create
call super::create
end on

on b1w_reg_trouble_categoryb_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_category_b

ls_category_b = Trim(dw_cond.Object.categoryb[1])

If IsNull(ls_category_b) Then ls_category_b = ""

ls_where = ""

If ls_category_b <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " troubletypeb.troubletypeb = '" + ls_category_b + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_new_category_b

SELECT SUBSTR(MAX(TROUBLETYPEB), 1, 1)||LPAD(TO_NUMBER(SUBSTR(MAX(TROUBLETYPEB), 2, 5)) + 1, 5, '0')
INTO   :ls_new_category_b
FROM   TROUBLETYPEB;

//ls_category_c = Trim(dw_cond.Object.categoryc[1])
//If IsNull(ls_category_c) Then ls_category_c = ""

//If ls_category_c <> "" Then 

//End If

//Insert 시 해당 row 장애종류명으로 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("troubletypeb_troubletypebnm")

//Log 정보
dw_detail.Object.troubletypeb_troubletypeb[al_insert_row] = ls_new_category_b
dw_detail.Object.troubletypeb_troubletypec[al_insert_row] = ls_new_category_b
dw_detail.object.troubletypeb_crt_user[al_insert_row] = gs_user_id
dw_detail.object.troubletypeb_crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.troubletypeb_updt_user[al_insert_row] = gs_user_id
dw_detail.object.troubletypeb_updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.troubletypeb_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

//dw_detail.SetItemStatus(al_insert_row, 0, primary!, NotModified!)

Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i, ll_no_save = 0
String ls_category_b, ls_category_bnm, ls_category_c, ls_svccod

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

ll_no_save = 0

//저장시 필수입력항목 CHECK
For ll_i = 1 To ll_row
	ls_category_b = Trim(dw_detail.Object.troubletypeb_troubletypeb[ll_i])
	ls_category_bnm = Trim(dw_detail.Object.troubletypeb_troubletypebnm[ll_i])	
	//ls_category_c = Trim(dw_detail.Object.troubletypeb_troubletypec[ll_i])
	ls_svccod = Trim(dw_detail.Object.troubletypeb_svccod[ll_i])
	
	If IsNull(ls_category_b) Then ls_category_b = ""
	If IsNull(ls_category_bnm) Then ls_category_bnm = ""
	//If IsNull(ls_category_c) Then ls_category_c = ""
	If IsNull(ls_svccod) Then ls_svccod = ""
	
	If ls_category_b = "" Then 
		f_msg_usr_err(200, Title, "민원유형 중분류코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypeb_troubletypeb")
		Return -1
	End If
	If ls_category_bnm = "" Then 
		f_msg_usr_err(200, Title, "민원유형 중분류명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypeb_troubletypebnm")
		Return -1
	End If
	//If ls_category_c = "" Then 
	//	f_msg_usr_err(200, Title, "민원유형 대분류코드")
	//	dw_detail.SetRow(ll_i)
	//	dw_detail.ScrollToRow(ll_i)
	//	dw_detail.SetColumn("troubletypeb_troubletypec")
	//	Return -1
	//End If
	If ls_svccod = "" Then 
		f_msg_usr_err(200, Title, "서비스")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypeb_svccod")
		Return -1
	End If
	
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.troubletypeb_updt_user[ll_i] = gs_user_id
		dw_detail.object.troubletypeb_updtdt[ll_i] = fdt_get_dbserver_now()
//		dw_detail.object.troubletypeb_pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]
   End If
	
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN //데이터 수정시!
		//TROUBLETYPEA UPDATE
		UPDATE TROUBLETYPEA
		SET    TROUBLETYPEANM = :ls_category_bnm,
				 UPDT_USER = :gs_user_id,
				 UPDTDT = SYSDATE
		WHERE  TROUBLETYPEA = :ls_category_b;
		
		IF SQLCA.SQLCODE <> 0 THEN
			f_msg_info(3010, This.Title, "TROUBLETYPEA UPDATE : " + SQLCA.SQLErrText)
			ROLLBACK;
			RETURN -1
		END IF
		
		//TROUBLETYPEC UPDATE
		UPDATE TROUBLETYPEC
		SET    TROUBLETYPECNM = :ls_category_bnm,
				 UPDT_USER = :gs_user_id,
				 UPDTDT = SYSDATE
		WHERE  TROUBLETYPEC = :ls_category_b;
		
		IF SQLCA.SQLCODE <> 0 THEN
			f_msg_info(3010, This.Title, "TROUBLETYPEC UPDATE : " + SQLCA.SQLErrText)
			ROLLBACK;
			RETURN -1
		END IF
	ELSEIF dw_detail.GetItemStatus(ll_i, 0, Primary!) = NewModified! THEN //데이터 입력시!	
		//TROUBLETYPEA INSERT		
		INSERT INTO TROUBLETYPEA ( TROUBLETYPEA, 	TROUBLETYPEANM, 	TROUBLETYPEB,
											CRT_USER, 		CRTDT,				PGM_ID )
		VALUES ( :ls_category_b, 	:ls_category_bnm, :ls_category_b,	&
					:gs_user_id,		SYSDATE,				:gs_pgm_id[gi_open_win_no]);
		
		IF SQLCA.SQLCODE <> 0 THEN
			f_msg_info(3010, This.Title, "TROUBLETYPEA INSERT : " + SQLCA.SQLErrText)
			ROLLBACK;
			RETURN -1
		END IF		
		
		//TROUBLETYPEC INSERT		
		INSERT INTO TROUBLETYPEC ( TROUBLETYPEC, 	TROUBLETYPECNM,
											CRT_USER, 		CRTDT,				PGM_ID )
		VALUES ( :ls_category_b, 	:ls_category_bnm, 	&
					:gs_user_id,		SYSDATE,				:gs_pgm_id[gi_open_win_no]);
		
		IF SQLCA.SQLCODE <> 0 THEN
			f_msg_info(3010, This.Title, "TROUBLETYPEC INSERT : " + SQLCA.SQLErrText)
			ROLLBACK;
			RETURN -1
		END IF
	ELSE
		ll_no_save += 1
	END IF			
Next

IF ll_row = ll_no_save THEN
	f_msg_info(3010, This.Title, "SAVE RECORD NOT FOUND! ")
	ROLLBACK;
	RETURN -1
END IF

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b1w_reg_categoryC
	Desc.	: 민원유형 중분류 등록
	Ver 	: 1.0
	Date	: 2003.08.12
	Progrmaer: Choo YoonShik(chooys)
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row,	ll_cnt = 0
Int  ii

FOR ii = 1 TO dw_detail.RowCount()
	IF dw_detail.GetItemStatus ( ii, 0, Primary!) = Newmodified! THEN
		ll_cnt += 1
	END IF
NEXT

IF ll_cnt > 0 THEN
	f_msg_usr_err(200, Title, "입력은 한건씩만 처리가능합니다.")
	RETURN -1
END IF

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If dw_detail.IsSelected( ll_row ) then
	dw_detail.SelectRow( ll_row ,FALSE)
Else
   dw_detail.SelectRow(0, FALSE )
	dw_detail.SelectRow( ll_row , TRUE )
End If

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0

p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)

Constant Int LI_ERROR = -1
Int li_rc

dw_detail.AcceptText()

dw_cond.SetColumn("categoryb")

p_insert.TriggerEvent("ue_enable")
//ii_error_chk = -1
If dw_detail.ModifiedCount() > 0 Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//ii_error_chk = 0
Return 0

Return 0
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space		
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

event type integer ue_extra_delete();call super::ue_extra_delete;STRING	ls_category_b
LONG		ll_row

dw_detail.AcceptText()

ll_row = dw_detail.GetRow()

If ll_row < 0 Then Return 0

ls_category_b = dw_detail.Object.troubletypeb_troubletypeb[ll_row]

//TROUBLETYPEA DELETE
DELETE FROM TROUBLETYPEA
WHERE  TROUBLETYPEA = :ls_category_b;

IF SQLCA.SQLCODE <> 0 THEN
	f_msg_info(3010, This.Title, "TROUBLETYPEA DELETE : " + SQLCA.SQLErrText)
	ROLLBACK;
	RETURN -1
END IF
		
//TROUBLETYPEC DELETE
DELETE FROM TROUBLETYPEC
WHERE  TROUBLETYPEC = :ls_category_b;

IF SQLCA.SQLCODE <> 0 THEN
	f_msg_info(3010, This.Title, "TROUBLETYPEC DELETE : " + SQLCA.SQLErrText)
	ROLLBACK;
	RETURN -1
END IF

//TROUBLETYPEB DELETE
DELETE FROM TROUBLETYPEB
WHERE  TROUBLETYPEB = :ls_category_b;

IF SQLCA.SQLCODE <> 0 THEN
	f_msg_info(3010, This.Title, "TROUBLETYPEB DELETE : " + SQLCA.SQLErrText)
	ROLLBACK;
	RETURN -1
END IF

Return 0

end event

event type integer ue_delete();Constant Int LI_ERROR = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	dw_detail.SetFocus()	
	Return LI_ERROR
ELSE
	COMMIT;
	f_msg_info(3000,This.Title,"DELETE")
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
End if

Return 0
end event

event closequery;Int li_rc

dw_detail.AcceptText()

If dw_detail.ModifiedCount() > 0 Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_trouble_categoryb_v20
integer x = 41
integer y = 40
integer width = 1595
integer height = 128
string dataobject = "b1dw_cnd_reg_trouble_categoryb"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_trouble_categoryb_v20
integer x = 2418
integer y = 64
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_trouble_categoryb_v20
integer x = 1221
integer y = 1736
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_trouble_categoryb_v20
integer width = 2715
integer height = 192
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_trouble_categoryb_v20
integer x = 329
integer y = 1736
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_trouble_categoryb_v20
integer y = 1736
end type

type p_save from w_a_reg_m`p_save within b1w_reg_trouble_categoryb_v20
integer x = 626
integer y = 1736
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_trouble_categoryb_v20
integer y = 224
integer width = 2715
integer height = 1472
string dataobject = "b1dw_reg_trouble_categoryb_v20"
end type

event dw_detail::constructor;SetTransObject(SQLCA)

dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::clicked;call super::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
End If

end event

event dw_detail::doubleclicked;//
end event

event dw_detail::itemchanged;//
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_trouble_categoryb_v20
integer x = 923
integer y = 1736
end type

