package org.cloudfoundry.training;


import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {

	private AppInfo appInfo;
	
	@Autowired
	public HomeController(AppInfo appInfo) {
		this.appInfo = appInfo;
	}

	@RequestMapping("/")
    public String index(Model model) throws SQLException {
		
		model.addAttribute("appName", appInfo.getAppName());
		model.addAttribute("instanceIndex", appInfo.getInstanceIndex());
		model.addAttribute("spaceName", appInfo.getSpaceName());
		model.addAttribute("database", appInfo.getDatabase());
		
        return "index";
    }
	
	@RequestMapping("/kill") 
	public void kill() {
		System.exit(1);
	}

}
