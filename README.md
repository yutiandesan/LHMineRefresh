# LHMineRefresh

use:
[refreshTableView addHeaderWithTarget:self action:@selector(headerRefresh)];

[refreshTableView headerBeginRefreshing];//手动调用下拉刷新


notice:No use it in UITableViewController,because self.tableView.superView is null.


The running result:

  ![The result](/refresh.gif) 





referred to:MJRefresh


blog Add:http://blog.sina.com.cn/s/blog_14e49abae0102wfvl.html
