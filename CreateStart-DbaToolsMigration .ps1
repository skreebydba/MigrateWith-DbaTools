function Start-DbaToolsMigration {
  <#
  .SYNOPSIS
  Executes the Start-DbaMigration function from DBATools
  .DESCRIPTION
  If all databases are to be migrated, all databases, logins, database mail profiles/accounts, credentials, SQL Agent objects, linked servers,
  Central Management Server objects, server configuration settings (sp_configure), user objects in systems databases,
  system triggers and backup devices will be migrated. 
  If a list of databases is to be migrated, all logins, database mail profiles/accounts, credentials, SQL Agent objects, linked servers, 
  Central Management Server objects, server configuration settings (sp_configure), user objects in systems databases, system triggers and backup devices will be
  migrated and each databases in the list will be migrated individually.

  .EXAMPLE
  Start-DbaToolsMigration -alldatabases Y -source fbgapisql01 -destination $fbgapisql03 -share "\\fbgapimigratedc\migration";
  .EXAMPLE
  Start-DbaToolsMigration -alldatabases N -source fbgapisql01 -destination $fbgapisql03 -share "\\fbgapimigratedc\migration" -databaselist WWI1, WWI2;
  .PARAMETER alldatabases
  Are all databases to be backed up - Y|N
  .PARAMETER databaselist
  Comma-delimited list of databases to be migrated - required if alldatabase -eq N
  .PARAMETER source
  Source instance to be migrated - required
  .PARAMETER destination
  Destination instance to be migrated to - required
  .PARAMETER share
  File share for database backups
  #>
  [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='Are you migrating all user databases [Y|N]?')]
    [Alias('alldbs')]
    [string]$alldatabases,
	[Parameter(Mandatory=$False,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='If you are not migrating all user databases, enter a comma-delimited list of databases to be migrated.')]
    [Alias('dblist')]
    [string]$databaselist,	
	[Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='Enter the SQL Server instance to be migrated.')]
    [Alias('src')]
    [string]$source,
	[Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='Enter the SQL Server instance being migrated to.')]
    [Alias('dest')]
    [string]$destination,
	[Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='Enter a file share that service accounts for source and destination instances can access.')]
    [Alias('path')]
    [string]$share
  )


  process {

        $databases = $databaselist.Split(',');

        if($alldatabases -eq 'Y')
        {
            Start-DbaMigration -Source $source -Destination $destination -NetworkShare $share -BackupRestore;
        }
        else
        {
            Start-DbaMigration -Source $source -Destination $destination -NetworkShare $share -BackupRestore -NoDatabases;
            foreach($database in $databases)
            {
                Write-Output "Some databases";
                $exists = (Get-DbaDatabase -SqlInstance $source -Database $database).Name;

                if($exists -ne $null)
                {
                    Write-Output "Source $source Destination $destination Databases $databaselist Network Share $share";
                    Copy-DbaDatabase -Source $source -Destination $destination -NetworkShare $share -Database $database -BackupRestore;
                }
                else
                {
                    Write-Output "Database $database does not exist on instance $source.  Please check the database name and resubmit.";
                }
            }
        }
    }
}
