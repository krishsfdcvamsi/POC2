/**
 *   Extends the DataSource.Provider base class to create a
 *   custom adapter for Salesforce Connect. The class informs
 *   Salesforce of the functional and authentication
 *   capabilities that are supported by or required to connect
 *   to an external system.
 **/
global class RFO_ExternalDataSourceProvider
        extends DataSource.Provider { 

    /**
     *   For simplicity, this example declares that the external 
     *   system doesn’t require authentication by returning
     *   AuthenticationCapability.ANONYMOUS as the sole entry 
     *   in the list of authentication capabilities.
     **/
    override global List<DataSource.AuthenticationCapability>
    getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities =
                new List<DataSource.AuthenticationCapability>();
        capabilities.add(
                DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }

    /**
     *   Declares the functional capabilities that the
     *   external system supports, in this case
     *   only SOQL queries.
     **/
    override global List<DataSource.Capability>
    getCapabilities() {
        List<DataSource.Capability> capabilities =
                new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
        return capabilities;
    }

    /**
     *   Declares the associated DataSource.Connection class.
     **/
    override global DataSource.Connection getConnection(
            DataSource.ConnectionParams connectionParams) {
        return new RFO_LCDataSourceConnection(connectionParams);
    }
}