$PBExportHeader$w_datashield_crypto.srw
$PBExportComments$PBD등 프로그램 DB 저장(Upload)
forward
global type w_datashield_crypto from w_a_reg_m
end type
type p_refresh from u_p_refresh within w_datashield_crypto
end type
type p_all from u_p_all within w_datashield_crypto
end type
end forward

global type w_datashield_crypto from w_a_reg_m
integer width = 3424
integer height = 1888
event ue_refresh ( )
event ue_all ( )
p_refresh p_refresh
p_all p_all
end type
global w_datashield_crypto w_datashield_crypto

type variables
//청구기준일
Date id_reqdt
String is_chargedt, is_reqdt
end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
end prototypes

event ue_refresh;//청구 작업 절차 마감 (취소하지 않겠다.)
Long i

If dw_detail.RowCount() = 0 Then Return 
For i  = 1  To dw_detail.RowCount()
	dw_detail.object.flag[i] = "C"
Next

//저장함
Post Event ue_save()

//다시 조회함.
Post Event ue_ok()
end event

event ue_all();//모든 고객을 할때. 첫번째 Row에 "All" 
dw_detail.object.payid[1] = "ALL"
dw_detail.object.paynm[1] = "ALL"

Return

end event

public function integer wfi_get_payid (string as_payid);Long ll_count
	
//모든 고객이면 Check 제외
If Upper(as_payid) = "ALL" Then Return 0 

Select count(*)
Into :ll_count
From reqinfo
Where payid = :as_payid;

If ll_count = 0 Then
	Return - 1
Else
	Return 0 
End IF

Return 0 
	
	
end function

on w_datashield_crypto.create
int iCurrent
call super::create
this.p_refresh=create p_refresh
this.p_all=create p_all
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_refresh
this.Control[iCurrent+2]=this.p_all
end on

on w_datashield_crypto.destroy
call super::destroy
destroy(this.p_refresh)
destroy(this.p_all)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: 	b5w_reg_invcan_per
	Desc	: 	청구작업 취소 대상자
	Date	: 	2003.01.03
	Ver.	: 	1.0
	Progrmaer : Choi Bo Ra(ceusee)
-------------------------------------------------------------------------*/
p_refresh.TriggerEvent("ue_disable")
p_all.TriggerEvent("ue_disable")

end event

event ue_ok;call super::ue_ok;//조회
String ls_where, ls_chargedt, ls_reqdt
Long ll_row

ls_chargedt = Trim(dw_cond.object.chargedt[1])
ls_reqdt = Trim(dw_cond.object.strdt[1])
If IsNull(ls_chargedt) Then ls_chargedt = ""

If ls_chargedt = "" Then
	f_msg_info(200, title, "Billing Cycle (Due Date)")
	dw_cond.SetFocus()
	dw_cond.SetColumn("chargedt")
	Return
End IF

ls_where = ""
//ls_where = "chargedt = '" + ls_chargedt + "' "
//ls_where += " And  to_char(trdt, 'yyyy-mm-dd') = '" + ls_reqdt + "' and flag is null "

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

event ue_extra_insert;call super::ue_extra_insert;//서버는 TLSv1.2 기반의 REST 방식으로 호출되며 송수신 데이터는 아래와 같이 JSON 형식의 요청과 응답으로 구성된다.
//즉, 어떤 언어든 이와 같은 형태로만 호출하도록 클라이언트를 구현하면 통신이 가능하다.
//
//<요청>
//{"appid":"CHOCY_APPS_ID_010101", "datatype":"01", "userid":“someid", "userip":“192.168.10.27", "data":["1234567890987","1234567890987"], "dataSize":2}
//
//<응답>
//{"code":"N0000", "message":null, "result":["0!egQpAC/QEE7x/er96j2omw==","0!egQpAC/QEE7x/er96j2omw=="]}
//

//http://172.20.45.204:40201/cipher/encAes.action  //암호화
//http://172.20.45.204:40201/cipher/decAes.action  //복호화
string ls_card_no

ls_card_no = dw_detail.object.card_no[1]

//ls_urlName = "http://172.20.45.204:40201/cipher/encAes.action"

//objectname.Submit(ls_urlName, ref string response, ref JsonPackage package)

HttpClient      lhc_Client
CoderObject     lco_Code
Jsonpackage     ljpg_json
String          ls_ClientID, ls_Sercet, ls_Auth, ls_Url, ls_PostData, ls_UserName, ls_Password, ls_scope, ls_Body, ls_Error
String          ls_Token, ls_TokenType, ls_AccessToken
Blob            lblb_data
Long            ll_return

lhc_Client = Create HttpClient
lco_Code = Create CoderObject
ljpg_json = Create Jsonpackage

//Step 1: Get the RESTful server access token.
//Url
// "https://authserver.appeon.com/oauth2/token"
////Authorization
//ls_ClientID = "367c4163ddc1427d96655cd220c6714b"
//ls_Sercet = "4079f8749939446cbc81fd0c27709187"
//lblb_data = Blob ( ls_ClientID + ":" + ls_Sercet, EncodingUTF8! )
//ls_Auth = lco_Code.Base64Encode( lblb_data )
//lhc_Client.SetRequestHeader( "Authorization", "Basic " + ls_Auth )
//lhc_Client.SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
////PostData
//ls_UserName = "username"
//ls_Password = "password123"
//ls_scope = "testcode"
ls_Url = "http://172.20.45.204:40201/cipher/encAes.action"

//{"appid":"CHOCY_APPS_ID_010101", "datatype":"01", "userid":“someid", "userip":“192.168.10.27", "data":["1234567890987","1234567890987"], "dataSize":2}

//ls_PostData = "grant_type=password&username="+ls_UserName+"&password="+ls_Password+"&scope=" + lco_Code.UrlEncode( Blob(ls_scope,EncodingUTF8!))
//ls_PostData = {"appid":"UBSUBSCARD01010103#0001", "datatype":"03", "data":"123456789123", "dataSize":1}
//
ll_return = lhc_Client.SendRequest( "POST", ls_Url, ls_PostData )
If ll_return = 1 And lhc_Client.GetResponsestatusCode() = 200 Then
         lhc_Client.GetResponseBody ( ls_body )
         ls_Error = ljpg_json.loadString ( ls_body )
         If ls_Error = "" then
                   ls_TokenType = ljpg_json.GetValue("token_type")
                   ls_Token = ljpg_json.GetValue("access_token")
                   ls_AccessToken = ls_TokenType + " " + ls_Token

                   //Step 2: Get the RESTful server resource.
                   ls_Url = "https://authserver.appeon.com/order/getall"
                   lhc_Client.ClearRequestHeaders()
                   lhc_Client.SetRequestHeader( "Authorization", ls_AccessToken )
                   ll_return = lhc_Client.SendRequest( "GET", ls_Url )
                   If ll_return = 1 And lhc_Client.GetResponsestatusCode() = 200 Then
                            lhc_Client.GetResponseBody ( ls_body )
                            MessageBox ( "Resource", ls_body )
                   Else
                            MessageBox( "ResourceResponse Falied", "Return :" + String ( ll_return ) + "~r~n" + lhc_Client.GetResponsestatusText() )
                   End If
                   
         Else
                   MessageBox( "Error", ls_Error )
         End If
Else
         MessageBox( "AccessToken Falied", "Return :" + String ( ll_return ) + "~r~n" + lhc_Client.GetResponsestatusText() )
End If

If IsValid ( lco_Code ) Then DesTroy ( lco_Code )
If IsValid ( ljpg_json ) Then DesTroy ( ljpg_json )
If IsValid ( lhc_Client ) Then DesTroy ( lhc_Client )



 


Return 0 
end event

event ue_extra_save;call super::ue_extra_save;////저장시 Check
//Long i, li_return, ll_seq
//String ls_payid
//
//For i = 1 To dw_detail.RowCount()
//	ls_payid = Trim(dw_detail.object.payid[i])
//	ll_seq = dw_detail.object.seq[i]
//	If IsNull(ls_payid) Then ls_payid = ""
//	If IsNull(ll_seq) Then ll_seq = 0
//	
//	If ls_payid = "" Then
//		f_msg_usr_err(210, title, "Payer ID")
//		dw_detail.SetRow(i)
//		dw_detail.ScrollToRow(i)
//		dw_detail.SetColumn("payid")
//		Return -2
//	Else
//		li_return = wfi_get_payid(ls_payid)
//		If li_return < 0 Then
//			f_msg_usr_err(201, title, "Payer ID")
//			dw_detail.SetRow(i)
//			dw_detail.ScrollToRow(i)
//			dw_detail.SetColumn("payid")
//			Return -2
//		End If
//   End If
//	
////	Seq 번호 부여
// If ll_seq = 0 Then 
//	Select Max(seq) + 1 
//	Into :ll_seq
//	From reqcan 
//	Where chargedt = :is_chargedt and to_char(trdt, 'yyyy-mm-dd') = :is_reqdt
//			and flag = 'C';
//   
//	If IsNull(ll_seq) Then ll_seq = 1
//	dw_detail.object.seq[i] = ll_seq
//End If
//	
//Next

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
	p_refresh.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_all.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_refresh.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_all.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

event type integer ue_reset();call super::ue_reset;p_refresh.TriggerEvent("ue_disable")
p_all.TriggerEvent("ue_disable")
Return 0 
end event

event type integer ue_delete();call super::ue_delete;If dw_detail.RowCount() = 0 then p_all.TriggerEvent("ue_disable")

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within w_datashield_crypto
integer x = 64
integer width = 1330
integer height = 340
string dataobject = "b5d_cnd_reg_invcan_per"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;//청구기준일과 사용기간 가져오기
String ls_startdt
Date ld_startdt
Date ld_use_fr, ld_use_to

If dwo.name = "chargedt" Then
	
	Select reqdt
	Into :id_reqdt
	From reqconf 
	Where to_char(chargedt) = :data;
	
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select Error(REQCONF)")
		Return 
	End If
	
	
	//청구기준일
	is_reqdt = String(id_reqdt, 'yyyy-mm-dd')
	This.object.strdt[1] = is_reqdt
	is_chargedt = data
	
	//사용기간 시작일
	ld_use_fr = fd_pre_month(id_reqdt, 1)
	//사용기간 종료일
	ld_use_to = fd_date_pre(id_reqdt, 1)
	
	This.object.usedt[1] = String(ld_use_fr, 'yyyy-mm-dd') + " ~~ " + String(ld_use_to, 'yyyy-mm-dd')
	
End If
	
end event

type p_ok from w_a_reg_m`p_ok within w_datashield_crypto
integer x = 1559
integer y = 52
end type

type p_close from w_a_reg_m`p_close within w_datashield_crypto
integer x = 1856
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within w_datashield_crypto
integer width = 1403
integer height = 404
end type

type p_delete from w_a_reg_m`p_delete within w_datashield_crypto
integer x = 329
integer y = 1660
end type

type p_insert from w_a_reg_m`p_insert within w_datashield_crypto
integer x = 27
integer y = 1660
end type

event p_insert::clicked;call super::clicked;p_all.TriggerEvent("ue_enable")
end event

type p_save from w_a_reg_m`p_save within w_datashield_crypto
integer x = 631
integer y = 1660
end type

type dw_detail from w_a_reg_m`dw_detail within w_datashield_crypto
integer y = 428
integer width = 3323
integer height = 1180
string dataobject = "dw_cardinfo_crypto"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_payid, ls_paynm
int    li_rc
//이름 셋팅
If dwo.name = "payid" Then
	
	ls_payid = Trim(This.object.payid[row])
	
	If IsNull(ls_payid) Then ls_payid = ""
		li_rc = wfi_get_payid(ls_payid)
		
	If li_rc < 0 Then
			dw_detail.Object.payid[1] = ""
			dw_detail.Object.paynm[1] = ""
	Else
	
	Select customernm
		  Into :ls_paynm
		  From customerm
		 where payid = :ls_payid
		 and   rownum = 1;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT svccod from svcmst")				
			Return 1
		End If
		
		If ls_payid <> 'ALL' Then
			dw_detail.Object.paynm[row] = ls_paynm
	   Else
			dw_detail.Object.paynm[row] = 'ALL'
	   End If
	End If
End If


end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_refresh.TriggerEvent("ue_enable")
	//p_all.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
Else
	p_refresh.TriggerEvent("ue_enable")
	//p_all.TriggerEvent("ue_enable")
End If

Return 0 
end event

event dw_detail::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[row] = iu_cust_help.is_data2[1]
			This.Object.paynm[row] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If
//	Case "customerid"
//		If iu_cust_help.ib_data[1] Then
//			This.Object.customerid[1] = iu_cust_help.is_data2[1]
//			This.Object.customernm[1] = iu_cust_help.is_data2[2]			
//		End If	
End Choose

AcceptText()

Return 0 
end event

event dw_detail::ue_init;call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"
end event

type p_reset from w_a_reg_m`p_reset within w_datashield_crypto
integer x = 1678
integer y = 1660
end type

type p_refresh from u_p_refresh within w_datashield_crypto
integer x = 928
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean enabled = false
end type

event clicked;call super::clicked;p_all.TriggerEvent("ue_disable")
end event

type p_all from u_p_all within w_datashield_crypto
integer x = 1221
integer y = 1660
boolean bringtotop = true
boolean enabled = false
end type

