<!--- 
<cf_transfirst 
	login=""
	tran_key=""
	system="live"
	card_num=""
	exp_date="YYMM"
	cvv=""
	amount="0.00" 
	decription=""
	first_name=""
	last_name=""
	address=""
	address2=""
	city=""
	state=""
	zip=""
	phone=""
	email=""
	/>

RETURNS:
	Variable called returnStr  (structure)
		returnStr.responseCode is 00 for success.  If not 00, returnStr.message has reason why
		OTHER RETURNS (see TransFirst guide for more information):
		returnStr.AVSCode	
		returnStr.Amount
		returnStr.AmtDueRemaining	
		returnStr.Auth	
		returnStr.CAVVResultCode
		returnStr.CVV2Response
		returnStr.CardBalance	
		returnStr.PostDate
		returnStr.tranNr

--->
<cfswitch expression="#thisTag.ExecutionMode#">
  <cfcase value="start">
		<cfif not isdefined('attributes.login')>
			ERROR: No gateway id supplied.<cfexit method="exittag" />
		</cfif>
		<cfif not isdefined('attributes.tran_key')>
			ERROR: No reg key supplied.<cfexit method="exittag" />
		</cfif>
		<cfparam name="attributes.country" default="" />
		<cfparam name="attributes.invoiceNumber" default="" />
		<cfparam name="attributes.system" default="live" />
		<cfparam name="attributes.address2" default="" />
		<cfparam name="attributes.phone" default="" />
		<cfparam name="attributes.email" default="" />

		<!--- converts $ to Cents --->
		<cfset attributes.amount = val(rereplace(attributes.amount,'[\$,]','','ALL')*100) />
		
		<cfif attributes.system IS "live">
			<cfset gatewayurl = "https://post.transactionexpress.com/PostMerchantService.svc/CreditCardSale" />
		<cfelse>
			<cfset gatewayurl = "https://post.cert.transactionexpress.com/PostMerchantService.svc/CreditCardSale" />
		</cfif>
		<!--- ColdFusion's cfhttp object is specifically designed to create a post,
		and retrieve the results.  Those results are accessed in cfhttp.filecontent --->
		<cfhttp method="Post" url="#gatewayurl#">
			<!--- the API Login ID and Transaction Key must be replaced with valid values --->
			<cfhttpparam type="Formfield" name="gatewayid" value="#attributes.login#">
			<cfhttpparam type="Formfield" name="regkey" value="#attributes.tran_key#">
		   
			<cfhttpparam type="Formfield" name="industrycode" value="2">

			<cfhttpparam type="Formfield" name="accountnumber" value="#attributes.card_num#">
			<cfhttpparam type="Formfield" name="expirationdate" value="#attributes.exp_date#"><!--- YYMM --->
			<cfhttpparam type="Formfield" name="cvv2" value="#attributes.cvv#">
		
			<cfhttpparam type="Formfield" name="amount" value="#attributes.amount#"><!--- No special chars --->
			<cfhttpparam type="Formfield" name="descriptor" value="#attributes.description#">
		
			<cfhttpparam type="Formfield" name="FullName" value="#attributes.first_name# #attributes.last_name#">
			<cfhttpparam type="Formfield" name="address" value="#attributes.address#">
			<cfhttpparam type="Formfield" name="address2" value="#attributes.address2#">
			<cfhttpparam type="Formfield" name="city" value="#attributes.city#">	
			<cfhttpparam type="Formfield" name="state" value="#attributes.state#">
			<cfhttpparam type="Formfield" name="zip" value="#attributes.zip#">
			<cfhttpparam type="Formfield" name="phonenumber" value="#attributes.phone#">
			<cfhttpparam type="Formfield" name="email" value="#attributes.email#">
		</cfhttp>
		
		<!--- <cfdump var="#cfhttp#"><cfabort> --->
		<cfset response=replace(cfhttp.filecontent, '"', '' ,'ALL')>
		
		<cfset response_array=ListToArray(response, "&")>
		
		<cfset returnStr = structNew() />
		<cfloop index="i" from="1" to="#arrayLen(response_array)#">
			<cfset returnStr[getToken(response_array[i],1,'=')] = getToken(response_array[i],2,'=') />
		</cfloop>
		<cfset returnStr.message=codeMessage(returnStr.responseCode) />

		<cfset caller.returnStr = returnStr />
		
  </cfcase>
  <cfcase value='end'>
    
  </cfcase>
</cfswitch>
<cffunction name="codeMessage">
	<cfargument name="code" />
	<cfswitch expression="#arguments.code#">
		<cfcase value="00">
			<cfset r = "" />
		</cfcase>
		<cfcase value="01"> <cfset r = "Refer to card issuer" /></cfcase>
		<cfcase value="02"> <cfset r = "Refer to card issuer, special condition" /></cfcase>
		<cfcase value="03"> <cfset r = "Invalid merchant" /></cfcase>
		<cfcase value="04"> <cfset r = "Pick-up card" /></cfcase>
		<cfcase value="05"> <cfset r = "Do not honor" /></cfcase>
		<cfcase value="06"> <cfset r = "Error" /></cfcase>
		<cfcase value="07"> <cfset r = "Pick-up card, special condition " /></cfcase>
		<cfcase value="08"> <cfset r = "Honor with identification (this is a decline response when a card not present transaction) If you receive an approval in a card not present environment, you will need to void the transaction. " /></cfcase>
		<cfcase value="09"> <cfset r = "Request in progress " /></cfcase>
		<cfcase value="10"> <cfset r = "Approved, partial authorization " /></cfcase>
		<cfcase value="11"> <cfset r = "VIP Approval (this is a decline response for a card not present transaction) " /></cfcase>
		<cfcase value="12"> <cfset r = "Invalid transaction " /></cfcase>
		<cfcase value="13"> <cfset r = "Invalid amount " /></cfcase>
		<cfcase value="14"> <cfset r = "Invalid card number " /></cfcase>
		<cfcase value="15"> <cfset r = "No such issuer " /></cfcase>
		<cfcase value="16"> <cfset r = "Approved, update track 3 " /></cfcase>
		<cfcase value="17"> <cfset r = "Customer cancellation " /></cfcase>
		<cfcase value="18"> <cfset r = "Customer dispute " /></cfcase>
		<cfcase value="19"> <cfset r = "Re-enter transaction " /></cfcase>
		<cfcase value="20"> <cfset r = "Invalid response " /></cfcase>
		<cfcase value="21"> <cfset r = "No action taken " /></cfcase>
		<cfcase value="22"> <cfset r = "Suspected malfunction " /></cfcase>
		<cfcase value="23"> <cfset r = "Unacceptable transaction fee " /></cfcase>
		<cfcase value="24"> <cfset r = "File update not supported " /></cfcase>
		<cfcase value="25"> <cfset r = "Unable to locate record " /></cfcase>
		<cfcase value="26"> <cfset r = "Duplicate record " /></cfcase>
		<cfcase value="27"> <cfset r = "File update field edit error " /></cfcase>
		<cfcase value="28"> <cfset r = "File update file locked " /></cfcase>
		<cfcase value="29"> <cfset r = "File update failed " /></cfcase>
		<cfcase value="30"> <cfset r = "Format error " /></cfcase>
		<cfcase value="31"> <cfset r = "Bank not supported " /></cfcase>
		<cfcase value="32"> <cfset r = "Completed partially " /></cfcase>
		<cfcase value="33"> <cfset r = "Expired card, pick-up " /></cfcase>
		<cfcase value="34"> <cfset r = "Suspected fraud, pick-up " /></cfcase>
		<cfcase value="35"> <cfset r = "Contact acquirer, pick-up " /></cfcase>
		<cfcase value="36"> <cfset r = "Restricted card, pick-up " /></cfcase>
		<cfcase value="37"> <cfset r = "Call acquirer security, pick-up " /></cfcase>
		<cfcase value="38"> <cfset r = "PIN tries exceeded, pick-up " /></cfcase>
		<cfcase value="39"> <cfset r = "No credit account " /></cfcase>
		<cfcase value="40"> <cfset r = "Function not supported " /></cfcase>
		<cfcase value="41"> <cfset r = "Lost card, pick-up " /></cfcase>
		<cfcase value="42"> <cfset r = "No universal account " /></cfcase>
		<cfcase value="43"> <cfset r = "Stolen card, pick-up " /></cfcase>
		<cfcase value="44"> <cfset r = "No investment account " /></cfcase>
		<cfcase value="45"> <cfset r = "Account closed " /></cfcase>
		<cfcase value="46"> <cfset r = "Identification required " /></cfcase>
		<cfcase value="47"> <cfset r = "Identification cross-check required " /></cfcase>
		<cfcase value="48"> <cfset r = "No customer record " /></cfcase>
		<cfcase value="49"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="50"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="51"> <cfset r = "Not sufficient funds " /></cfcase>
		<cfcase value="52"> <cfset r = "No checking account " /></cfcase>
		<cfcase value="53"> <cfset r = "No savings account " /></cfcase>
		<cfcase value="54"> <cfset r = "Expired card " /></cfcase>
		<cfcase value="55"> <cfset r = "Incorrect PIN " /></cfcase>
		<cfcase value="56"> <cfset r = "No card record " /></cfcase>
		<cfcase value="57"> <cfset r = "Transaction not permitted to cardholder " /></cfcase>
		<cfcase value="58"> <cfset r = "Transaction not permitted on terminal " /></cfcase>
		<cfcase value="59"> <cfset r = "Suspected fraud " /></cfcase>
		<cfcase value="60"> <cfset r = "Contact acquirer " /></cfcase>
		<cfcase value="61"> <cfset r = "Exceeds withdrawal limit " /></cfcase>
		<cfcase value="62"> <cfset r = "Restricted card " /></cfcase>
		<cfcase value="63"> <cfset r = "Security violation " /></cfcase>
		<cfcase value="64"> <cfset r = "Original amount incorrect " /></cfcase>
		<cfcase value="65"> <cfset r = "Exceeds withdrawal frequency " /></cfcase>
		<cfcase value="66"> <cfset r = "Call acquirer security " /></cfcase>
		<cfcase value="67"> <cfset r = "Hard capture " /></cfcase>
		<cfcase value="68"> <cfset r = "Response received too late " /></cfcase>
		<cfcase value="69"> <cfset r = "Advice received too late " /></cfcase>
		<cfcase value="70"> <cfset r = "Reserved for future use " /></cfcase>
		<cfcase value="71"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="72"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="73"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="74"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="75"> <cfset r = "PIN tries exceeded " /></cfcase>
		<cfcase value="76"> <cfset r = "Reversal: Unable to locate previous message (no match on Retrieval Reference Number)/ Reserved for future Realtime use" />
		</cfcase>
		<cfcase value="77"> <cfset r = "Previous message located for a repeat or reversal, but repeat or reversal data is inconsistent with original message/ Intervene, bank approval required " /></cfcase>
		<cfcase value="78"> <cfset r = "Invalid/non-existent account – Decline (MasterCard specific)/ Intervene, bank approval required for partial amount" /></cfcase>
		<cfcase value="79"> <cfset r = "Already reversed (by Switch)/ Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="80"> <cfset r = "No financial Impact (Reserved for declined debit)/ Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="81"> <cfset r = "PIN cryptographic error found by the Visa security module during PIN decryption/ Reserved for client-specific use (declined)" /></cfcase>
		<cfcase value="82"> <cfset r = "Incorrect CVV/ Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="83"> <cfset r = "Unable to verify PIN/ Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="84"> <cfset r = "Invalid Authorization Life Cycle – Decline (MasterCard) or Duplicate Transaction Detected (Visa)/Reserved for client-specific use (declined)" /></cfcase>
		<cfcase value="85"> <cfset r = "No reason to decline a request for Account Number Verification or Address Verification/ Reserved for client-specific use (declined)" /></cfcase>
		<cfcase value="86"> <cfset r = "Cannot verify PIN/ Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="87"> <cfset r = "Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="88"> <cfset r = "Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="89"> <cfset r = "Reserved for client-specific use (declined) " /></cfcase>
		<cfcase value="90"> <cfset r = "Cut-off in progress " /></cfcase>
		<cfcase value="91"> <cfset r = "Issuer or switch inoperative " /></cfcase>
		<cfcase value="92"> <cfset r = "Routing error " /></cfcase>
		<cfcase value="93"> <cfset r = "Violation of law " /></cfcase>
		<cfcase value="94"> <cfset r = "Duplicate Transmission (Integrated Debit and MasterCard) " /></cfcase>
		<cfcase value="95"> <cfset r = "Reconcile error " /></cfcase>
		<cfcase value="96"> <cfset r = "System malfunction " /></cfcase>
		<cfcase value="97"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="98"> <cfset r = "Exceeds cash limit " /></cfcase>
		<cfcase value="99"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="0A"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="A0"> <cfset r = "Reserved for future Realtime use " /></cfcase>
		<cfcase value="A1"> <cfset r = "ATC not incremented " /></cfcase>
		<cfcase value="A2"> <cfset r = "ATC limit exceeded " /></cfcase>
		<cfcase value="A3"> <cfset r = "ATC configuration error " /></cfcase>
		<cfcase value="A4"> <cfset r = "CVR check failure " /></cfcase>
		<cfcase value="A5"> <cfset r = "CVR configuration error " /></cfcase>
		<cfcase value="A6"> <cfset r = "TVR check failure " /></cfcase>
		<cfcase value="A7"> <cfset r = "TVR configuration error " /></cfcase>
		<cfcase value="B1"> <cfset r = "Surcharge amount not permitted on Visa cards or EBT Food Stamps/ Reserved for future Realtime use " /></cfcase>
		<cfcase value="B2"> <cfset r = "Surcharge amount not supported by debit network issuer/ Reserved for future Realtime use " /></cfcase>
		<cfcase value="C0"> <cfset r = "Unacceptable PIN " /></cfcase>
		<cfcase value="C1"> <cfset r = "PIN Change failed " /></cfcase>
		<cfcase value="C2"> <cfset r = "PIN Unblock failed " /></cfcase>
		<cfcase value="C3"> <cfset r = "to D0 Reserved for future Realtime use " /></cfcase>
		<cfcase value="D1"> <cfset r = "MAC Error " /></cfcase>
		<cfdefaultcase>
			<cfset r = "Unknown Error" />
		</cfdefaultcase>
	</cfswitch>
	<cfreturn r />
</cffunction>
