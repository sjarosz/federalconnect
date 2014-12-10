<%--
   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
  
   Copyright (c) 2008 Sun Microsystems Inc. All Rights Reserved
  
   The contents of this file are subject to the terms
   of the Common Development and Distribution License
   (the License). You may not use this file except in
   compliance with the License.

   You can obtain a copy of the License at
   https://opensso.dev.java.net/public/CDDLv1.0.html or
   opensso/legal/CDDLv1.0.txt
   See the License for the specific language governing
   permission and limitations under the License.

   When distributing Covered Code, include this CDDL
   Header Notice in each file and include the License file
   at opensso/legal/CDDLv1.0.txt.
   If applicable, add the following below the CDDL Header,
   with the fields enclosed by brackets [] replaced by
   your own identifying information:
   "Portions Copyrighted [year] [name of copyright owner]"

   $Id: index.jsp,v 1.14 2009/06/09 20:28:30 exu Exp $

--%>

 <%--
    Portions Copyrighted 2013/2014 ForgeRock AS
 --%>


<%@ page import="com.sun.identity.saml2.common.SAML2Exception" %>
<%@ page import="com.sun.identity.saml2.meta.SAML2MetaException" %>
<%@ page import="com.sun.identity.saml2.meta.SAML2MetaManager" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.owasp.esapi.ESAPI" %>

<%@ include file="header.jspf" %>
<%--
    index.jsp contains links to test SP or IDP initiated Single Sign-on
--%>
<%
    String deployuri = request.getContextPath();
    String gatewayuri = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort();

    String[] appNames = {"myportal"}; // Fill with OpenIG Routes




    String fedletHomeDir = System.getProperty("com.sun.identity.fedlet.home");
    if ((fedletHomeDir == null) || (fedletHomeDir.trim().length() == 0)) {
        if (System.getProperty("user.home").equals(File.separator)) {
            fedletHomeDir = File.separator + "fedlet";
        } else {
            fedletHomeDir = System.getProperty("user.home") +
                File.separator + "fedlet";
        }
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-GB">
<head>
    <title>FederalConnect</title>
    <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="layout.css" media="screen" />
    <link rel="stylesheet" type="text/css" href="style.css" />
    <script type="text/javascript" src="jquery-2.1.1.js"></script>  
    <script type="text/javascript" src="config.js"></script>  
    <script type="text/javascript" src="functions.js"></script>  


    <script type="text/javascript" src="data-driver.js"></script>


</head>
<body>
<div id="header">
    <h3><img src="img/small-logo.png"/>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#f1e732">FederalConnect</font></h3>
        <p id="layoutdims">

<a href="https://wikis.forgerock.org/confluence/display/OPENIG/FederalConnect+-+Plug+into+Connect.gov>online documentation</a>

</div>




<%
    // Retreive the metadata information 
    String spEntityID = null;
    String spMetaAlias = null;
    String idpEntityID = null;
    String idpMetaAlias= null;
    boolean createConfig = false; 
    // check need to create configuration
    String param = request.getParameter("CreateConfig");
    if ((param != null) && param.equalsIgnoreCase("true")) {
        createConfig = true;
    } 
    try {
        if (createConfig) {
            // copy all files under conf to fedletHomeDir
            String[] files = new String[] {
                "FederationConfig.properties",
                "idp.xml",
                "idp-extended.xml",
                "sp.xml",
                "sp-extended.xml",
                "fedlet.cot"};
            File dir = new File(fedletHomeDir);
            if (!dir.exists()) {
                if (!dir.mkdirs()) {
                    throw new SAML2Exception("Failed to create Fedlet " +
                        "configuration home directory " + fedletHomeDir);
                }
            } else if (dir.isFile()) {
                throw new SAML2Exception("Fedlet configuration home " + 
                    fedletHomeDir + " is a pre-existing file. <br>Please " +
                    "remove the file and try again."); 
            } 
            ServletContext servletCtx = getServletConfig().getServletContext();
            for (int i = 0; i < files.length; i++) {
                String source = "/conf/" + files[i];
                String dest =  dir.getPath() + File.separator + files[i];
                FileOutputStream fos = null;
                InputStream src = null;
                try {
                    src = servletCtx.getResourceAsStream(source);
                    if (src != null) {
                        fos = new FileOutputStream(dest);
                        int length = 0;
                        byte[] bytes = new byte[1024];
                        while ((length = src.read(bytes)) != -1) {
                            fos.write(bytes, 0, length);
                        }
                    } else {
                        throw new SAML2Exception("File " + source + 
                            " could not be found in fedlet.war");
                    }
                } catch (IOException e) {
                    throw new SAML2Exception(e.getMessage());
                } finally {
                    try {
                        if (fos != null) {
                            fos.close();
                        }
                        if (src != null) {
                            src.close();
                        }
                    } catch (IOException ex) {
                        //ignore
                    }
                }
            }
            out.println("<p><br><b>Fedlet configuration created under \"" +
                fedletHomeDir + "\" directory.</b>");
            out.println("<br><br>Click <a href=\"index.jsp\">here</a> to continue.");
        } else {
            // check if this WAR contain Fedlet configuration
            boolean confExist = false;
            InputStream src = getServletConfig().getServletContext().
                getResourceAsStream("/conf/FederationConfig.properties");
            if (src != null) {
                confExist = true;
            }

            File dir = new File(fedletHomeDir);
            File file = new File(fedletHomeDir + File.separator + 
                "FederationConfig.properties");
            if (!dir.exists() || !dir.isDirectory()) {
                out.println("<p><br><b>Fedlet configuration home directory does not exist.</b>");
                if (confExist) {
                    out.println("<br><br>Click <a href=\"index.jsp?CreateConfig=true\">here</a> to create Fedlet configuration automatically.");
                    out.println("<br>Or manually extract your fedlet.war and copy all files under \"conf\" directory to \"" + fedletHomeDir + "\" directory, then restart your web container.");
                } else {
                    out.println("<br>Please follow the README bundled inside your Fedlet-unconfigured.zip file to setup Fedlet configuration, then restart your web container.");
                }
            } else if (!file.exists()) {
                out.println("<p><br><b>FederationConfig.properties could not be found.</b>");
                if (confExist) {
                    out.println("<br><br>Click <a href=\"index.jsp?CreateConfig=true\">here</a> to create Fedlet configuration automatically.");
                    out.println("<br>Or manually extract your fedlet.war and copy all files under \"conf\" directory to \"" + fedletHomeDir + "\" directory, then restart your web container.");
                } else {
                    out.println("<br>Please follow the README bundled inside your Fedlet-unconfigured.zip file to setup Fedlet configuration, then restart your web container.");
                }
            } else {
                SAML2MetaManager manager = new SAML2MetaManager();
                List spEntities = 
                    manager.getAllHostedServiceProviderEntities("/");
                if ((spEntities != null) && !spEntities.isEmpty()) {
                    // get first one
                    spEntityID = (String) spEntities.get(0);
                }

                List spMetaAliases =
                    manager.getAllHostedServiceProviderMetaAliases("/");
                if ((spMetaAliases != null) && !spMetaAliases.isEmpty()) {
                    // get first one
                    spMetaAlias = (String) spMetaAliases.get(0);
                }

                List trustedIDPs = new ArrayList();
                idpEntityID = request.getParameter("idpEntityID");
                if (!ESAPI.validator().isValidInput("HTTP Parameter Value: " +
                    idpEntityID, idpEntityID, "HTTPParameterValue", 2000, true)){
                        idpEntityID = null;
                }
                if ((idpEntityID == null) || (idpEntityID.length() == 0)) {
                    // find out all trusted IDPs
                    List idpEntities = 
                        manager.getAllRemoteIdentityProviderEntities("/");
                    if ((idpEntities != null) && !idpEntities.isEmpty()) {
                        int numOfIDP = idpEntities.size();
                        for (int j = 0; j < numOfIDP; j ++) {
                            String idpID = (String) idpEntities.get(j); 
                            if (manager.isTrustedProvider("/", 
                                spEntityID, idpID)) {
                                trustedIDPs.add(idpID);
                            }
                        }
                    }
                }
                if (trustedIDPs.size() > 1) {
                    // multiple trusted IDPs
                    int numOfIDP = trustedIDPs.size();
                    out.println("<p><br><b>Multiple Identity Providers are configured with this Fedlet.</b><br>");
                    out.println("<br><b>Please select the Identity Provider to validate the Fedlet setup :</b><br>");
                    String thisURI = request.getRequestURI();
                    if (thisURI.indexOf("?") != -1) {
                        thisURI = thisURI + "&";
                    } else {
                        thisURI = thisURI + "?";
                    }
                    for (int j = 0; j < numOfIDP; j ++) {
                        idpEntityID = (String) trustedIDPs.get(j); 
                        out.println("<br><a href=\"" + thisURI + "idpEntityID=" 
                            + idpEntityID + "\">" + idpEntityID + "</a>");
                    }
                    out.println("<br><br><b>or </b><br>");
                    out.println("<a href=\"" + deployuri + 
                        "/saml2/jsp/fedletSSOInit.jsp?metaAlias=" + spMetaAlias
                        + "\">use IDP discovery service to find out preferred IDP</a>");
                    out.println("</body>");
                    out.println("</html>");
                    return;
                } else if (!trustedIDPs.isEmpty()) {  
                    // get the single IDP entity ID 
                    idpEntityID = (String) trustedIDPs.get(0);
                }
                if ((spEntityID == null) || (idpEntityID == null)) {
                    out.println("<p><br><b>Fedlet or remote Identity Provider metadata is not configured.</b>");
                    if (confExist) {
                        out.println("<p><br>Click <a href=\"index.jsp?CreateConfig=true\">here</a> to create Fedlet configuration automatically.");
                        out.println("<br>Or manually extract your fedlet.war and copy all files under \"conf\" directory to \"" + fedletHomeDir + "\" directory, then restart your web container.");
                    } else {
                        out.println("<br>Please follow the README bundled inside your Fedlet-unconfigured.zip file to setup Fedlet configuration, then restart your web container.");
                    }
                } else {
                    // IDP base URL
                    Map idpMap = getIDPBaseUrlAndMetaAlias(
                        idpEntityID, deployuri);
                    String idpBaseUrl = (String)idpMap.get("idpBaseUrl");
                    idpMetaAlias = (String)idpMap.get("idpMetaAlias");
                    String fedletBaseUrl = 
                        getFedletBaseUrl(spEntityID,deployuri);
%>
    <h2>Configure</h2>
    <p><br>
    <table border="0" width="700">
    <tr>
       <td colspan="2">
          Click following links to start FederalConnect 
          Login at the requested LOA from approved credential providers.</td>
    </tr> 
    <tr>
      <td><b>FederalConnect Configuration Directory:&nbsp;&nbsp;</b></td> <td><%= fedletHomeDir %></td>
    </tr>
    <tr>
      <td><b>SP Entity ID:</b>&nbsp;&nbsp;&nbsp;&nbsp;</td> <td><%= spEntityID %></td><td><a href="<%= deployuri %>/saml2/jsp/exportmetadata.jsp" target="_blank">show</a>&nbsp;&nbsp;</td><td></td>
    </tr>
    <tr>
      <td><b>(Connect.gov) IDP Entity ID:</b></td> <td><%= idpEntityID %></td><td><a href="<%= deployuri %>/saml2/jsp/exportmetadata.jsp?entityid=<%= java.net.URLEncoder.encode(idpEntityID)%>" target="_blank">show</a>&nbsp;&nbsp;</td></td>
    </tr>
</table>
<br><br>
    <h2>Test</h2>
    <table border="0" width="700">
      <td colspan="2"> </td>
    </tr>
    <tr>
      <td colspan="2"> </td>
    </tr>
    <tr>


      <td colspan="2"><a href="<%= gatewayuri %>/saml/SPInitiatedSSO?metaAlias=<%= spMetaAlias %>&idpEntityID=<%= idpEntityID%>&reqBinding=urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect&AttributeConsumingServiceIndex=1&AuthnContextClassRef=http%3A%2F%2Fidmanagement.gov%2Ficam%2F2009%2F12%2Fsaml_2.0_profile%2Fassurancelevel1&AllowCreate=true&NameIDFormat=urn:oasis:names:tc:SAML:2.0:nameid-format:persistent&RelayState=<%= gatewayuri %>/myportal/showHeaders.jsp">Login to Connect.gov requesting LOA1</a></td>
    </tr>

    <tr>
      <td colspan="2"><a href="<%= gatewayuri %>/saml/SPInitiatedSSO?metaAlias=<%= spMetaAlias %>&idpEntityID=<%= idpEntityID%>&reqBinding=urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect&AttributeConsumingServiceIndex=1&AuthnContextClassRef=http%3A%2F%2Fidmanagement.gov%2Ficam%2F2009%2F12%2Fsaml_2.0_profile%2Fassurancelevel2&AllowCreate=true&NameIDFormat=urn:oasis:names:tc:SAML:2.0:nameid-format:persistent">Login to Connect.gov requesting LOA2</a></td>
    </tr>

    <tr>
      <td colspan="2"><a href="<%= gatewayuri %>/saml/SPInitiatedSSO?metaAlias=<%= spMetaAlias %>&idpEntityID=<%= idpEntityID%>&reqBinding=urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect&AttributeConsumingServiceIndex=1&AuthnContextClassRef=http%3A%2F%2Fidmanagement.gov%2Ficam%2F2009%2F12%2Fsaml_2.0_profile%2Fassurancelevel3&AllowCreate=true&NameIDFormat=urn:oasis:names:tc:SAML:2.0:nameid-format:persistent">Login to Connect.gov requesting LOA3</a></td>
    </tr>

     <tr>
      <td colspan="2"><a href="<%= gatewayuri %>/saml/SPInitiatedSSO?metaAlias=<%= spMetaAlias %>&idpEntityID=<%= idpEntityID%>&reqBinding=urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect&AttributeConsumingServiceIndex=1&AuthnContextClassRef=http%3A%2F%2Fidmanagement.gov%2Ficam%2F2009%2F12%2Fsaml_2.0_profile%2Fassurancelevel4&AllowCreate=true&NameIDFormat=urn:oasis:names:tc:SAML:2.0:nameid-format:persistent">Login to Connect.gov requesting LOA4</a></td>
    </tr>           


    <tr>
      <td colspan="2"> </td>
    </tr>
    </table>
<%
                }
            }
        }
    } catch (SAML2MetaException se) {
        se.printStackTrace();
        response.sendError(response.SC_INTERNAL_SERVER_ERROR, se.getMessage());
        return;
    } catch (SAML2Exception sse) {
        sse.printStackTrace();
        response.sendError(response.SC_INTERNAL_SERVER_ERROR, sse.getMessage());
        return;
    }
%>
<br><br>

</table>
</div>    
<div id="footer">
    <p>Copyright 2014 ForgeRock AS || also checkout <a href="https://forgerock.agency-x.gov:9443/openam/UI/Login?ForceAuth=true&service=adminconsoleservice&goto=https://forgerock.agency-x.gov:9443/openam/base/AMAdminFrame">OpenAM</a>||<a href="">OpenIG</a>||<a href="">OpenIDM</a>||<a href="">OpenDJ</a></p>
</div>
</body>
</html>
