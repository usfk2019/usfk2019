$PBExportHeader$b0w_reg_connection_priceplan_1_v20.srw
$PBExportComments$[ssong] 접속료 발생 가격정책 등록
forward
global type b0w_reg_connection_priceplan_1_v20 from w_a_reg_m
end type
end forward

global type b0w_reg_connection_priceplan_1_v20 from w_a_reg_m
integer width = 2281
integer height = 1920
end type
global b0w_reg_connection_priceplan_1_v20 b0w_reg_connection_priceplan_1_v20

type variables
Boolean ib_check

String is_svccod, is_customer_type, is_carrier_type
end variables

on b0w_reg_connection_priceplan_1_v20.create
call super::create
end on

on b0w_reg_connection_priceplan_1_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_sacnum_kind, ls_check

ls_sacnum_kind	= Trim( dw_cond.Object.sacnum_kind[1] )
ls_check = Trim(dw_cond.Object.check[1])

If ls_check = "Y" then	
	ib_check = True
Else 
	ib_check = False
End If

IF( IsNull(ls_sacnum_kind) ) THEN ls_sacnum_kind = ""


If ls_sacnum_kind = "" Then
		f_msg_Info(200, Title, "접속료유형")
		dw_cond.SetFocus()
		dw_cond.SetColumn("sacnum_kind")
   	 Return 
	End If	


//Dynamic SQL
ls_where = ""
IF ls_sacnum_kind <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "sacnum_kind = '" + ls_sacnum_kind + "' AND customer_type = '" + is_carrier_type + "' "
END IF

/*dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF*/

dw_detail.SetRedraw(False)

If ib_check Then
	dw_detail.DataObject = "b0dw_reg_det_connection_priceplan_v20"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
	
Else
	dw_detail.DataObject = "b0dw_reg_det_connection_priceplan_1_v20"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
End If

//Retrieve
ll_rows	= dw_detail.Retrieve()
dw_detail.SetRedraw(True)

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF
end event

event ue_extra_save;call super::ue_extra_save;String	ls_sacnum_kind, ls_priceplan, ls_customer_type, ls_connectfee_type, ls_check, ls_svccod
Long		ll_rows, ll_rowcnt
Long     ll_cnt, ll_cnt_1

dw_detail.AcceptText()

ls_check = Trim(dw_cond.Object.check[1])

ll_rows	= dw_detail.RowCount()

If ls_check = "Y" then	
FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_sacnum_kind	= Trim(dw_detail.Object.sacnum_kind[ll_rowcnt])
	IF IsNull(ls_sacnum_kind) THEN ls_sacnum_kind = ""
	
	ls_svccod = Trim(dw_detail.Object.svccod[ll_rowcnt])
	IF IsNull(ls_svccod) THEN ls_svccod = ""
	
	ls_priceplan	= Trim(dw_detail.Object.priceplan[ll_rowcnt])
	IF IsNull(ls_priceplan) THEN ls_priceplan = ""
		
	ls_connectfee_type	= Trim(dw_detail.Object.connectfee_type[ll_rowcnt])
	IF IsNull(ls_connectfee_type) THEN ls_connectfee_type = ""
	
	
	
	//서비스코드체크
	IF ls_sacnum_kind = "" THEN
		f_msg_usr_err(200, Title, "접속료 유형")
		dw_detail.setColumn("sacnum_kind")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_priceplan = "" THEN
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.setColumn("priceplan")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_connectfee_type = "" THEN
		f_msg_usr_err(200, Title, "발생방법")
		dw_detail.setColumn("connectfee_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
		
	select count(priceplan)
  into :ll_cnt
  from connection_priceplan
 where priceplan = 'ALL'
   and sacnum_kind = :ls_sacnum_kind
	and customer_type = '100'
	and svccod = :ls_svccod;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	select count(priceplan)
  into :ll_cnt_1
  from connection_priceplan
 where sacnum_kind    = :ls_sacnum_kind
   and svccod = :ls_svccod
	and customer_type = '100'
   and priceplan <> 'ALL' ;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	If ll_cnt > 0 then
		If ls_priceplan <> 'ALL' Then
	  	f_msg_usr_err(201, Title, "해당 서비스에 이미 ALL 가격정책이 등록되어 있습니다. 다른서비스에 해당하는 가격정책을  선택하십시오.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("svccod")
		Return -2
	End If
	elseif ll_cnt = 0 then
		if ls_priceplan = 'ALL' then 
			IF ll_cnt_1 >= 1 Then
				f_msg_usr_err(201, Title, "해당서비스에 ALL이 아닌 가격정책이 등록되어 있습니다. 가격정책별로 접속료 가격정책을 등록하시기 바랍니다.")
				dw_cond.SetFocus()
				dw_cond.SetColumn("check")
				Return -2
			end if	
		End If
	End If
	
Next	
	
Else 
	    
   FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_sacnum_kind	= Trim(dw_detail.Object.sacnum_kind[ll_rowcnt])
	IF IsNull(ls_sacnum_kind) THEN ls_sacnum_kind = ""
	
	ls_svccod	= Trim(dw_detail.Object.svccod[ll_rowcnt])
	IF IsNull(ls_svccod) THEN ls_svccod = ""
	
	ls_priceplan = Trim(dw_detail.Object.priceplan[ll_rowcnt])
	If IsNull(ls_priceplan) THEN ls_priceplan = ""
		
	ls_connectfee_type	= Trim(dw_detail.Object.connectfee_type[ll_rowcnt])
	IF IsNull(ls_connectfee_type) THEN ls_connectfee_type = ""
	
	//서비스코드체크
	IF ls_sacnum_kind = "" THEN
		f_msg_usr_err(200, Title, "접속료 유형")
		dw_detail.setColumn("sacnum_kind")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_svccod = "" THEN
		f_msg_usr_err(200, Title, "서비스")
		dw_detail.setColumn("svccod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_connectfee_type = "" THEN
		f_msg_usr_err(200, Title, "발생방법")
		dw_detail.setColumn("connectfee_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	select count(priceplan)
  into :ll_cnt
  from connection_priceplan
 where priceplan = 'ALL'
   and sacnum_kind = :ls_sacnum_kind
	and customer_type = '100'
	and svccod = :ls_svccod;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	select count(priceplan)
  into :ll_cnt_1
  from connection_priceplan
 where sacnum_kind    = :ls_sacnum_kind
   and svccod = :ls_svccod
	and customer_type = '100'
   and priceplan <> 'ALL' ;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	If ll_cnt > 0 then
	  if ls_priceplan <>  'ALL' then
		f_msg_usr_err(201, Title, "해당 서비스에 이미 ALL 가격정책이 등록되어 있습니다. 다른서비스를 선택하십시오.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("svccod")
		Return -2
	End If
	elseif ll_cnt = 0 then
		if ls_priceplan = 'ALL' then 
			IF ll_cnt_1 >= 1 Then
				f_msg_usr_err(201, Title, "해당서비스에 ALL이 아닌 가격정책이 등록되어 있습니다. 가격정책별로 접속료 가격정책을 등록하시기 바랍니다.")
				dw_cond.SetFocus()
				dw_cond.SetColumn("check")
				Return -2
			end if	
		End If
	End If
NEXT
End If

/*ll_rows	= dw_detail.RowCount()


FOR ll_rowcnt=1 TO ll_rows
	
	If ib_check then
		

ll_rows	= dw_detail.RowCount()
FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_sacnum_kind	= Trim(dw_detail.Object.sacnum_kind[ll_rowcnt])
	IF IsNull(ls_sacnum_kind) THEN ls_sacnum_kind = ""
	
	ls_svccod = Trim(dw_detail.Object.svccod[ll_rowcnt])
	IF IsNull(ls_svccod) THEN ls_svccod = ""
	
	ls_priceplan	= Trim(dw_detail.Object.priceplan[ll_rowcnt])
	IF IsNull(ls_priceplan) THEN ls_priceplan = ""
		
	ls_connectfee_type	= Trim(dw_detail.Object.connectfee_type[ll_rowcnt])
	IF IsNull(ls_connectfee_type) THEN ls_connectfee_type = ""
	
	
	
	//서비스코드체크
	IF ls_sacnum_kind = "" THEN
		f_msg_usr_err(200, Title, "접속료 유형")
		dw_detail.setColumn("sacnum_kind")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_priceplan = "" THEN
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.setColumn("priceplan")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_connectfee_type = "" THEN
		f_msg_usr_err(200, Title, "발생방법")
		dw_detail.setColumn("connectfee_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	select count(priceplan)
  into :ll_cnt
  from connection_priceplan
 where priceplan = 'ALL'
   and sacnum_kind = :ls_sacnum_kind
	and svccod = :ls_svccod;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	select count(priceplan)
  into :ll_cnt_1
  from connection_priceplan
 where sacnum_kind    = :ls_sacnum_kind
   and svccod = :ls_svccod
   and priceplan <> 'ALL' ;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	If ll_cnt > 0 then
	  	f_msg_usr_err(201, Title, "해당 서비스에 이미 ALL 가격정책이 등록되어 있습니다. 다른서비스에 해당하는 가격정책을  선택하십시오.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("svccod")
		Return -2
	elseif ll_cnt = 0 then
		if ls_priceplan = 'ALL' then 
			IF ll_cnt_1 >= 1 Then
				f_msg_usr_err(201, Title, "해당서비스에 ALL이 아닌 가격정책이 등록되어 있습니다. 가격정책별로 접속료 가격정책을 등록하시기 바랍니다.")
				dw_cond.SetFocus()
				dw_cond.SetColumn("check")
				Return -2
			end if	
		End If
	End If
	
Next	
	
Else
  ll_rows	= dw_detail.RowCount()


FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_sacnum_kind	= Trim(dw_detail.Object.sacnum_kind[ll_rowcnt])
	IF IsNull(ls_sacnum_kind) THEN ls_sacnum_kind = ""
	
	ls_svccod	= Trim(dw_detail.Object.svccod[ll_rowcnt])
	IF IsNull(ls_svccod) THEN ls_svccod = ""
	
	ls_priceplan = Trim(dw_detail.Object.priceplan[ll_rowcnt])
	If IsNull(ls_priceplan) THEN ls_priceplan = ""
		
	ls_connectfee_type	= Trim(dw_detail.Object.connectfee_type[ll_rowcnt])
	IF IsNull(ls_connectfee_type) THEN ls_connectfee_type = ""
	
	//서비스코드체크
	IF ls_sacnum_kind = "" THEN
		f_msg_usr_err(200, Title, "접속료 유형")
		dw_detail.setColumn("sacnum_kind")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스명 체크
	IF ls_svccod = "" THEN
		f_msg_usr_err(200, Title, "서비스")
		dw_detail.setColumn("svccod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//서비스유형 체크
	IF ls_connectfee_type = "" THEN
		f_msg_usr_err(200, Title, "발생방법")
		dw_detail.setColumn("connectfee_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	select count(priceplan)
  into :ll_cnt
  from connection_priceplan
 where priceplan = 'ALL'
   and sacnum_kind = :ls_sacnum_kind
	and svccod = :ls_svccod;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	select count(priceplan)
  into :ll_cnt_1
  from connection_priceplan
 where sacnum_kind    = :ls_sacnum_kind
   and svccod = :ls_svccod
   and priceplan <> 'ALL' ;

	If SQLCA.SQLCode < 0 Then	
		f_msg_sql_err(title,  " Select Error" )
		Return -2 	
	End if
	
	If ll_cnt > 0 then
	  if ls_priceplan <>  '' then
		f_msg_usr_err(201, Title, "해당 서비스에 이미 ALL 가격정책이 등록되어 있습니다. 다른서비스를 선택하십시오.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("svccod")
		Return -2
	End If
	elseif ll_cnt = 0 then
		if ls_priceplan = 'ALL' then 
			IF ll_cnt_1 >= 1 Then
				f_msg_usr_err(201, Title, "해당서비스에 ALL이 아닌 가격정책이 등록되어 있습니다. 가격정책별로 접속료 가격정책을 등록하시기 바랍니다.")
				dw_cond.SetFocus()
				dw_cond.SetColumn("check")
				Return -2
			end if	
		End If
	End If
NEXT
	
End If*/
	
	
	
	//all 가격정책 count
//select count(priceplan)
//  into :ll_cnt
//  from connection_priceplan
// where priceplan = 'ALL'
//   and sacnum_kind   = :ls_sacnum_kind
//	and svccod = :ls_svccod;
//
//If SQLCA.SQLCode < 0 Then	
//	f_msg_sql_err(title,  " Select Error" )
//	Return -2 	
//End if
//
////all <> 가격정책 count
//select count(priceplan)
//  into :ll_cnt_1
//  from connection_priceplan
// where sacnum_kind    = :ls_sacnum_kind
//   and svccod = :ls_svccod
//   and priceplan <> 'ALL' ;
//
//If SQLCA.SQLCode < 0 Then	
//	f_msg_sql_err(title,  " Select Error" )
//	Return -2 	
//End if
//
//If ll_cnt > 0 then
////	if ls_priceplan <>  'ALL' then 
//		f_msg_usr_err(201, Title, "다른 서비스(가격정책)을 선택하십시오.")
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("priceplan")
//		Return -2
////	end if
//elseif ll_cnt = 0 then
//	if ls_priceplan = 'ALL' then 
//		IF ll_cnt_1 >= 1 Then
//			f_msg_usr_err(201, Title, "다른 서비스를 선택하십시오.")
//			dw_detail.SetFocus()
//			dw_detail.SetColumn("svccod")
//			Return -2
//		end if	
//	End If
//End If

//	//업데이트 처리
//	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
//		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
//		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
//	END IF



//No Error
RETURN 0
end event

event ue_reset;call super::ue_reset;dw_cond.Object.sacnum_kind[1] = ""

dw_cond.SetColumn("sacnum_kind")


RETURN 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insertion Log
String ls_check 
//
ls_check = Trim(dw_cond.Object.check[1])

//If IsNull(ls_check) then ls_check = "N"

If ls_check = "Y" then	
	ib_check = True
Else 
	ib_check = False
End If

//Insert
dw_detail.Object.sacnum_kind[al_insert_row]    = Trim(dw_cond.object.sacnum_kind[1])
dw_detail.object.customer_type[al_insert_row] = '200'

If ib_check = False  then
dw_detail.object.priceplan[al_insert_row]    = 'ALL'
End If

RETURN 0
end event

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b0w_reg_connection_priceplan_v20
	Desc.	:	접속료 발생 가격정책
	Ver	: 	1.0
	Date	: 	2005.07.20
	Prgromer : Song Eun Mi
---------------------------------------------------------------------------*/

String ls_ref_desc, ls_temp, ls_name[]


ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("00", "Z940", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_customer_type = ls_name[1]
is_carrier_type = ls_name[2]
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_connection_priceplan_1_v20
integer x = 37
integer width = 1541
integer height = 132
string dataobject = "b0dw_reg_cnd_connection_priceplan_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_connection_priceplan_1_v20
integer x = 1641
integer y = 32
end type

type p_close from w_a_reg_m`p_close within b0w_reg_connection_priceplan_1_v20
integer x = 1934
integer y = 32
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_connection_priceplan_1_v20
integer x = 23
integer width = 1573
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_connection_priceplan_1_v20
integer x = 315
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_connection_priceplan_1_v20
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b0w_reg_connection_priceplan_1_v20
integer x = 608
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_connection_priceplan_1_v20
integer x = 23
integer y = 212
integer width = 2194
integer height = 1412
string dataobject = "b0dw_reg_det_connection_priceplan_1_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

event dw_detail::itemchanged;call super::itemchanged;
String ls_priceplan, ls_svccod

If dw_detail.DataObject = "b0dw_reg_det_connection_priceplan_v20" Then

	Choose Case dwo.name
		
		Case "priceplan"
		ls_priceplan = Trim(This.object.priceplan[row])
		
		Select svccod
		  Into :ls_svccod
		  From priceplanmst
		 where priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT svccod from svcmst")				
			Return 1
		End If
		
		dw_detail.Object.svccod[row] = ls_svccod
		
	End Choose
End If
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_connection_priceplan_1_v20
integer y = 1664
end type

