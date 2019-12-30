$PBExportHeader$b5w_inq_billfile_create_popup.srw
$PBExportComments$[ohj] 청구file 생성-popup
forward
global type b5w_inq_billfile_create_popup from w_a_inq_s
end type
type p_1 from u_p_create within b5w_inq_billfile_create_popup
end type
end forward

global type b5w_inq_billfile_create_popup from w_a_inq_s
integer width = 2414
integer height = 920
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_create ( )
p_1 p_1
end type
global b5w_inq_billfile_create_popup b5w_inq_billfile_create_popup

type variables
String  is_cnd_invf_type, is_cnd_pay_method, is_cnd_inv_type, is_cnd_chargedt, &
        is_cnd_bankpay, is_cnd_creditpay, is_cnd_etcpay
Date    id_workdt, id_inputclosedt, id_cnd_trdt
Integer li_return
end variables

event ue_create();//Integer li_return

is_cnd_invf_type  = fs_snvl(dw_cond.object.cnd_invf_type[1] ,  '')
is_cnd_chargedt   = fs_snvl(dw_cond.object.cnd_chargedt[1]  ,  '')
is_cnd_pay_method = fs_snvl(dw_cond.object.cnd_pay_method[1], 'N')  	//giro
is_cnd_bankpay    = fs_snvl(dw_cond.object.cnd_bankpay[1]   , 'N') 	//자동이체
is_cnd_creditpay  = fs_snvl(dw_cond.object.cnd_creditpay[1] , 'N') 	//카드
is_cnd_etcpay     = fs_snvl(dw_cond.object.cnd_etcpay[1]    , 'N') 	//기타
is_cnd_inv_type   = fs_snvl(dw_cond.object.cnd_inv_type[1]  ,  '')	//청구서 유형
id_workdt         = dw_cond.object.cnd_workdt[1]
id_inputclosedt   = dw_cond.object.cnd_inputclosedt[1]
id_cnd_trdt       = dw_cond.object.cnd_trdt[1]  							//청구기준일

//If is_cnd_pay_method = 'Y'   Then is_cnd_pay_method = '1'  //지로
//If is_cnd_bankpay    = 'Y'   Then is_cnd_bankpay    = '2'  //자동이체
//If is_cnd_creditpay  = 'Y'   Then is_cnd_creditpay  = '3'  //카드

SetPointer(HourGlass!)

//필수 항목 check 
If is_cnd_invf_type = "" Then
	f_msg_usr_err(200, Title, "Bill File Type")
	dw_cond.SetColumn("cnd_invf_type")
	Return 
End If

If is_cnd_chargedt = "" Then
	f_msg_usr_err(200, Title, "Bii Cycle")
	dw_cond.SetColumn("cnd_chargedt")
	Return 
End If


If is_cnd_pay_method = 'N' And is_cnd_bankpay = 'N' And is_cnd_creditpay = 'N' And is_cnd_etcpay = 'N' Then
	f_msg_usr_err(200, Title, "Pay Method 중 한가지는 선택하여야 합니다.")
	dw_cond.SetColumn("cnd_pay_method")
	Return 
End If

Integer li_rc
////***** 처리부분 *****
b5u_dbmgr9 iu_db

iu_db = Create b5u_dbmgr9
iu_db.is_title = Title
iu_db.is_data[1] = is_cnd_invf_type
iu_db.is_data[2] = is_cnd_pay_method	 
iu_db.is_data[3] = is_cnd_inv_type	
iu_db.is_data[4] = is_cnd_chargedt				
iu_db.is_data[5] = is_cnd_bankpay
iu_db.is_data[6] = is_cnd_creditpay
iu_db.is_data[7] = is_cnd_etcpay
iu_db.is_data[8] = gs_user_id
iu_db.is_data[9] = gs_pgm_id[gi_open_win_no]

iu_db.id_data[1] = id_workdt	
iu_db.id_data[2] = id_inputclosedt
iu_db.id_data[3] = id_cnd_trdt

//iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_02()
li_rc	= iu_db.ii_rc

If li_rc < 0 Then
//	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy b5u_dbmgr9
	Return 
End If

//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy b5u_dbmgr9

li_return = li_rc

//wf_billfile_create()
////u_cust_db_app iu_cust_db_app
//li_return = 

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()

	Case -2
		dw_cond.SetFocus()
	Case -1
		rollback;
		
		f_msg_info(3010, Title,"Save")
				
	Case Is >= 0
		commit;
		//This.Trigger Event ue_ok()
		
		f_msg_info(3000, Title,"Save")
		TriggerEvent("ue_close")
	   //iu_cust_msg.idw_data[1].Trigger Event ue_ok()
End Choose	
	//ii_error_chk = 0
	//p_new.TriggerEvent("ue_enable")
	
Return 

SetPointer(Arrow!)
end event

event open;call super::open;/*-------------------------------------------------------
	Name	: b5w_inq_billfile_create_popup
	Desc.	: 
	Ver.	: 1.0
	Date	: 2005.02.23
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row
String ls_itemcod

//iu_mdb_app = Create u_cust_db_app

f_center_window(b5w_inq_billfile_create_popup)

dw_cond.SetItem(1, 'cnd_workdt', fdt_get_dbserver_now() )
dw_cond.SetItem(1, 'cnd_inputclosedt', fdt_get_dbserver_now() )
dw_cond.SetItem(1, 'cnd_pay_method', 'Y')

//TriggerEvent("ue_ok")

//dw_cond.object.priceplan[1] = iu_cust_msg.is_data[1]



Return 0 

end event

on b5w_inq_billfile_create_popup.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b5w_inq_billfile_create_popup.destroy
call super::destroy
destroy(this.p_1)
end on

type dw_cond from w_a_inq_s`dw_cond within b5w_inq_billfile_create_popup
integer width = 1902
integer height = 724
string dataobject = "b5dw_inq_billfile_create_popup"
end type

event dw_cond::itemchanged;call super::itemchanged;Choose Case dwo.name
	Case "cnd_chargedt"
		
		Date ld_reqdt
		SELECT REQDT
		  INTO :ld_reqdt
		  FROM REQCONF
		 WHERE CHARGEDT = :data ;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "select Error(REQCONF)")
			Return -1
			
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_sql_err(Title, "select no-data(REQCONF)")

		Else
			dw_cond.SetItem(row, 'cnd_trdt', ld_reqdt)
		
		End If		
		  
End Choose

Return 0
end event

type p_ok from w_a_inq_s`p_ok within b5w_inq_billfile_create_popup
boolean visible = false
end type

type p_close from w_a_inq_s`p_close within b5w_inq_billfile_create_popup
integer x = 2071
integer y = 156
end type

type gb_cond from w_a_inq_s`gb_cond within b5w_inq_billfile_create_popup
integer width = 1938
integer height = 792
end type

type dw_detail from w_a_inq_s`dw_detail within b5w_inq_billfile_create_popup
boolean visible = false
integer x = 165
integer y = 900
integer width = 1902
integer height = 752
end type

event dw_detail::itemchanged;call super::itemchanged;Choose Case dwo.name
	Case "cnd_chargedt"
		
		Date ld_reqdt
		SELECT REQDT
		  INTO :ld_reqdt
		  FROM REQCONF
		 WHERE CHARGEDT = :data ;

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "select Error(REQCONF)")
			Return -1
			
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_sql_err(Title, "select no-data(REQCONF)")

		Else
			dw_cond.SetItem(row, 'cnd_trdt', ld_reqdt)
		
		End If		
		  
End Choose

Return 0
end event

type p_1 from u_p_create within b5w_inq_billfile_create_popup
integer x = 2071
integer y = 52
boolean bringtotop = true
end type

