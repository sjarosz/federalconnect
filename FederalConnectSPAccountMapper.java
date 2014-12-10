


package com.forgerock.federalconnect;
import com.sun.identity.saml2.plugins.*;

public class FederalConnectSPAccountMapper extends DefaultLibrarySPAccountMapper {

     /**
      * Default constructor
      */
     public FederalConnectSPAccountMapper() {
         super();
         debug.message("FederalConnectSPAccountMapper.constructor: ");
     }

    /**
     * Ignore profile by returning true 
     * @param realm
     * @return true
     */
     @Override
    protected boolean isDynamicalOrIgnoredProfile(String realm) {

        return true;
    }

}
