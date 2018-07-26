package org.cloudfoundry.training;

public class AppInfo {

	public static final String MYSQL = "MySQL";
	public static final String H2 = "H2";
	
	private String appName;
	private int instanceIndex;
	private String spaceName;
	private String database;
	
	public AppInfo() {}

	public AppInfo(String appName, int instanceIndex, String spaceName, String database) {
		this.appName = appName;
		this.instanceIndex = instanceIndex;
		this.spaceName = spaceName;
		this.database = database;
	}

	public String getAppName() {
		return appName;
	}

	public int getInstanceIndex() {
		return instanceIndex;
	}

	public String getSpaceName() {
		return spaceName;
	}

	public String getDatabase() {
		return database;
	}
	
	
}
