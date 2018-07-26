package org.cloudfoundry.training;

import java.sql.SQLException;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.cloud.config.java.AbstractCloudConfig;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("cloud")
public class CloudAppInfoConfig extends AbstractCloudConfig {
	
	
	public final String APP_NAME_KEY = "application_name";
	public final String INSTANCE_INDEX_KEY = "instance_index";
	public final String SPACE_NAME_KEY = "space_name";
	
	@Bean
	public AppInfo appInfo() throws SQLException {
		Map<String,Object> properties = cloud().getApplicationInstanceInfo().getProperties();
		

		String appName = (String)properties.get(APP_NAME_KEY);
		int instanceIndex = (int)properties.get(INSTANCE_INDEX_KEY);
		String spaceName = (String)properties.get(SPACE_NAME_KEY);
		String database = getDatabase();
		return new AppInfo(appName, instanceIndex, spaceName, database);
	}
	
    private String getDatabase() throws SQLException {
        DataSource dataSource = null;
        try {
        	dataSource = cloud().getSingletonServiceConnector(DataSource.class, null);
        } catch (Exception e) {}
        if (dataSource == null) {
        	return AppInfo.H2;
        } else if ( isMySQL(dataSource)) {
            return AppInfo.MYSQL;
        } else {
        	 return dataSource.getConnection().getMetaData().getDriverName();
        }
    }

    private boolean isMySQL(DataSource dataSource) throws SQLException {
      return dataSource.getConnection().getMetaData().getDriverName().toLowerCase().contains("mysql");
    }
    
}
