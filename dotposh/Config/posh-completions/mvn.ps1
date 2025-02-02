#
# Maven PowerShell Completion
#
# References:
# - https://github.com/krymtkts/MavenAutoCompletion
# - https://github.com/juven/maven-bash-completion
#
# This file is heavily based on krymtkts's completion script. I
# modified it as to keep it up-to-date with new Maven 3 version,
# with extra `mvn` completion plugin-goals + missing options.
#

# Define Maven options and long options.
$MvnShortOpts = '-am', '-amd', '-B', '-b', '-C', '-c', '-cpu', '-D', '-e', '-emp', '-ep', '-f', '-fae', '-ff', '-fn', '-gs', '-gt', '-h', '-itr', '-l', '-llr', '-N', '-npr', '-npu', '-nsu', '-ntp', '-o', '-P', '-pl', '-q', '-rf', '-s', '-T', '-t', '-U', '-up', '-V', '-v', '-X'
$MvnLongOpts = '--also-make', '--also-make-dependents', '--batch-mode', '--builder', '--strict-checksums', '--lax-checksums', '--color', '--check-plugin-updates', '--define', '--errors', '--encrypt-master-password', '--encrypt-password', '--file', '--fail-at-end', '--fail-fast', '--fail-never', '--global-settings', '--global-toolchains', '--help', '--ignore-transitive-repositories', '--log-file', '--legacy-local-repository', '--non-recursive', '--no-plugin-registry', '--no-plugin-updates', '--no-snapshot-updates', '--no-transfer-progress', '--offline', '--activate-profiles', '--projects', '--quiet', '--resume-from', '--settings', '--threads', '--toolchains', '--update-snapshots', '--update-plugins', '--show-version', '--version', '--debug'

# Define common lifecycle phases.
$MvnCommonLifecyclePhases = {
	$CommonCleanLifecycle = 'pre-clean', 'clean', 'post-clean'
	$CommonDefaultLifecycle = 'validate', 'initialize', 'generate-sources', 'process-sources', 'generate-resources', 'process-resources', 'compile', 'process-classes', 'generate-test-sources', 'process-test-sources', 'generate-test-resources', 'process-test-resources', 'test-compile', 'process-test-classes', 'test', 'prepare-package', 'package', 'pre-integration-test', 'integration-test', 'post-integration-test', 'verify', 'install', 'deploy'
	$CommonSiteLifecycle = 'pre-site', 'site', 'post-site', 'site-deploy'
	$CommonCleanLifecycle + $CommonDefaultLifecycle + $CommonSiteLifecycle
}.Invoke()

# Define plugin goals.
# - https://maven.apache.org/plugins/index.html
$MvnPluginGoals = @{
	'acr:'                  = 'acr:acr'
	'android:'              = 'android:apk', 'android:apklib', 'android:clean', 'android:deploy', 'android:deploy-dependencies', 'android:dex', 'android:emulator-start', 'android:emulator-stop', 'android:emulator-stop-all', 'android:generate-sources', 'android:help', 'android:instrument', 'android:manifest-update', 'android:pull', 'android:push', 'android:redeploy', 'android:run', 'android:undeploy', 'android:unpack', 'android:version-update', 'android:zipalign', 'android:devices'
	'animal-sniffer:'       = 'animal-sniffer:build', 'animal-sniffer:check'
	'antrun:'               = 'antrun:run'
	'apache-rat:'           = 'apache-rat:ceck', 'apache-rat:rat'
	'appengine:'            = 'appengine:backends_configure', 'appengine:backends_delete', 'appengine:backends_rollback', 'appengine:backends_start', 'appengine:backends_stop', 'appengine:backends_update', 'appengine:debug', 'appengine:devserver', 'appengine:devserver_start', 'appengine:devserver_stop', 'appengine:endpoints_get_client_lib', 'appengine:endpoints_get_discovery_doc', 'appengine:enhance', 'appengine:rollback', 'appengine:set_default_version', 'appengine:start_module_version', 'appengine:stop_module_version', 'appengine:update', 'appengine:update_cron', 'appengine:update_dos', 'appengine:update_indexes', 'appengine:update_queues', 'appengine:vacuum_indexes'
	'archetype:'            = 'archetype:generate', 'archetype:create-from-project', 'archetype:crawl', 'archetype:jar', 'archetype:integration-test', 'archetype:update-local-catalog'
	'artifact:'             = 'artifact:buildinfo', 'artifact:compare', 'artifact:check-buildplan', 'artifact:describe-build-output', 'artifact:reproducible-central'
	'assembly:'             = 'assembly:help', 'assembly:single'
	'build-helper:'         = 'build-helper:add-source', 'build-helper:add-test-source', 'build-helper:add-resource', 'build-helper:add-test-resource', 'build-helper:attach-artifact', 'build-helper:regex-property', 'build-helper:regex-properties', 'build-helper:released-version', 'build-helper:parse-version', 'build-helper:reserve-network-port', 'build-helper:local-ip', 'build-helper:hostname', 'build-helper:cpu-count', 'build-helper:timestamp-property', 'build-helper:uptodate-property', 'build-helper:uptodate-properties', 'build-helper:rootlocation'
	'buildnumber:'          = 'buildnumber:create', 'buildnumber:create-timestamp', 'buildnumber:help', 'buildnumber:hgchangeset'
	'buildplan:'            = 'buildplan:list', 'buildplan:list-phase', 'buildplan:list-plugin', 'buildplan:report'
	'cargo:'                = 'cargo:start', 'cargo:run', 'cargo:stop', 'cargo:restart', 'cargo:configure', 'cargo:package', 'cargo:daemon-start', 'cargo:daemon-stop', 'cargo:deploy', 'cargo:undeploy', 'cargo:deployer-deploy', 'cargo:deployer:undeploy', 'cargo:deployer-start', 'cargo:deployer-stop', 'cargo:deployer-redeploy', 'cargo:redeploy', 'cargo:uberwar', 'cargo:install', 'cargo:help'
	'cassandra:'            = 'cassandra:start', 'cassandra:stop', 'cassandra:start-cluster', 'cassandra:stop-cluster', 'cassandra:run', 'cassandra:load', 'cassandra:repair', 'cassandra:flush', 'cassandra:compact', 'cassandra:cleanup', 'cassandra:delete', 'cassandra:cql-exec'
	'castor:'               = 'castor:generate', 'castor:mapping', 'castor:mappings', 'castor:dtdToXsd'
	'changelog:'            = 'changelog:changelog', 'changelog:dev-activity', 'changelog:file-activity'
	'changes:'              = 'changes:announcement-mail', 'changes:announcement-generate', 'changes:changes-check', 'changes:changes-validate', 'changes:changes', 'changes:jira-changes', 'changes:trac-changes', 'changes:github-changes'
	'checkstyle:'           = 'checkstyle:checkstyle', 'checkstyle:checkstyle-aggregate', 'checkstyle:check'
	'clirr:'                = 'clirr:check', 'clirr:clirr', 'clirr:check-arbitrary', 'clirr:check-no-fork'
	'clover:'               = 'clover:aggregate', 'clover:check', 'clover:instrumentInternal', 'clover:instrument', 'clover:log', 'clover:clover', 'clover:save-history'
	'cobertura:'            = 'cobertura:cobertura'
	'cyclonedx:'            = 'cyclonedx:makeAggregateBom', 'cyclonedx:makeBom', 'cyclonedx:makePackageBom'
	'dependency-check:'     = 'dependency-check:aggregate', 'dependency-check:check', 'dependency-check:help', 'dependency-check:purge', 'dependency-check:update-only'
	'dependency:'           = 'dependency:analyze', 'dependency:analyze-dep-mgt', 'dependency:analyze-exclusions', 'dependency:analyze-only', 'dependency:analyze-report', 'dependency:analyze-duplicate', 'dependency:build-classpath', 'dependency:collect', 'dependency:copy', 'dependency:copy-dependencies', 'dependency:display-ancestors', 'dependency:get', 'dependency:go-offline', 'dependency:list', 'dependency:list-classes', 'dependency:list-repositories', 'dependency:properties', 'dependency:purge-local-repository', 'dependency:resolve', 'dependency:resolve-plugins', 'dependency:resolve-sources', 'dependency:tree', 'dependency:unpack', 'dependency:unpack-dependencies'
	'doap:'                 = 'doap:generate'
	'docker:'               = 'docker:build', 'docker:start', 'docker:run', 'docker:stop', 'docker:push', 'docker:watch', 'docker:remove', 'docker:logs', 'docker:copy', 'docker:source', 'docker:save', 'docker:volume-create', 'docker:volume-remove'
	'ear:'                  = 'ear:ear', 'ear:generate-application-xml'
	'eclipse:'              = 'eclipse:clean', 'eclipse:eclipse'
	'ejb:'                  = 'ejb:ejb'
	'enforcer:'             = 'enforcer:enforce'
	'exec:'                 = 'exec:exec', 'exec:java'
	'failsafe:'             = 'failsafe:integration-test', 'failsafe:verify'
	'flatten:'              = 'flatten:flatten', 'flatten:clean'
	'findbugs:'             = 'findbugs:findbugs', 'findbugs:gui', 'findbugs:help'
	'flyway:'               = 'flyway:migrate', 'flyway:clean', 'flyway:info', 'flyway:validate', 'flyway:baseline', 'flyway:repair'
	'gpg:'                  = 'gpg:sign', 'gpg:sign-and-deploy-file'
	'grails:'               = 'grails:clean', 'grails:config-directories', 'grails:console', 'grails:create-controller', 'grails:create-domain-class', 'grails:create-integration-test', 'grails:create-pom', 'grails:create-script', 'grails:create-service', 'grails:create-tag-lib', 'grails:create-unit-test', 'grails:exec', 'grails:generate-all', 'grails:generate-controller', 'grails:generate-views', 'grails:help', 'grails:init', 'grails:init-plugin', 'grails:install-templates', 'grails:list-plugins', 'grails:maven-clean', 'grails:maven-compile', 'grails:maven-functional-test', 'grails:maven-grails-app-war', 'grails:maven-test', 'grails:maven-war', 'grails:package', 'grails:package-plugin', 'grails:run-app', 'grails:run-app-https', 'grails:run-war', 'grails:set-version', 'grails:test-app', 'grails:upgrade', 'grails:validate', 'grails:validate-plugin', 'grails:war'
	'gwt:'                  = 'gwt:browser', 'gwt:clean', 'gwt:compile', 'gwt:compile-report', 'gwt:css', 'gwt:debug', 'gwt:eclipse', 'gwt:eclipseTest', 'gwt:generateAsync', 'gwt:help', 'gwt:i18n', 'gwt:mergewebxml', 'gwt:resources', 'gwt:run', 'gwt:run-codeserver', 'gwt:sdkInstall', 'gwt:source-jar', 'gwt:soyc', 'gwt:test'
	'help:'                 = 'help:active-profiles', 'help:all-profiles', 'help:describe', 'help:effective-pom', 'help:effective-settings', 'help:evaluate', 'help:system'
	'hibernate3:'           = 'hibernate3:hbm2ddl', 'hibernate3:help'
	'idea:'                 = 'idea:clean', 'idea:idea'
	'invovker:'             = 'invoker:install', 'invoker:integration-test', 'invoker:verify', 'invoker:run', 'invoker:report'
	'jacoco:'               = 'jacoco:check', 'jacoco:dump', 'jacoco:help', 'jacoco:instrument', 'jacoco:merge', 'jacoco:prepare-agent', 'jacoco:prepare-agent-integration', 'jacoco:report', 'jacoco:report-aggregate', 'jacoco:report-integration', 'jacoco:restore-instrumented-classes'
	'jalopy:'               = 'jalopy:configure', 'jalopy:format'
	'jar:'                  = 'jar:jar', 'jar:test-jar'
	'jarsigner:'            = 'jarsigner:sign', 'jarsigner:verify'
	'javacc:'               = 'javacc:javacc', 'javacc:jjtree-javacc', 'javacc:jjtree', 'javacc:jtb-javacc', 'javacc:jtb', 'javacc:jjdoc'
	'javadoc:'              = 'javadoc:javadoc', 'javadoc:test-javadoc', 'javadoc:javadoc-no-fork', 'javadoc:aggregate', 'javadoc:test-aggregate', 'javadoc:aggregate-no-fork', 'javadoc:test-aggregate', 'javadoc:jar', 'javadoc:test-jar', 'javadoc:aggregate-jar', 'javadoc:test-aggregate-jar', 'javadoc:fix', 'javadoc:test-fix', 'javadoc:resource-bundle', 'javadoc:test-resource-bundle'
	'jboss-as:'             = 'jboss-as:add-resource', 'jboss-as:deploy', 'jboss-as:deploy-only', 'jboss-as:deploy-artifact', 'jboss-as:redeploy', 'jboss-as:redeploy-only', 'jboss-as:undeploy', 'jboss-as:undeploy-artifact', 'jboss-as:run', 'jboss-as:start', 'jboss-as:shutdown', 'jboss-as:execute-commands'
	'jboss:'                = 'jboss:start', 'jboss:stop', 'jboss:deploy', 'jboss:undeploy', 'jboss:redeploy'
	'jdepend:'              = 'jdepend:generate', 'jdepend:generate-no-fork'
	'jdeprscan:'            = 'jdeprscan:jdeprscan', 'jdeprscan:test-jdeprscan', 'jdeprscan:list', 'jdeprscan:help'
	'jdeps:'                = 'jdeps:jdkinternals', 'jdeps:test-jdkinternals'
	'jetty:'                = 'jetty:run', 'jetty:run-war', 'jetty:start', 'jetty:start-war', 'jetty:stop', 'jetty:effective-web-xml'
	'jgitflow:'             = 'jgitflow:feature-start', 'jgitflow:feature-finish', 'jgitflow:release-start', 'jgitflow:release-finish', 'jgitflow:hotfix-start', 'jgitflow:hotfix-finish', 'jgitflow:build-number'
	'jlink:'                = 'jlink:jlink', 'jlink:help'
	'jmod:'                 = 'jmod:create', 'jmod:list', 'jmod:describe', 'jmod:help'
	'jxr:'                  = 'jxr:jxr', 'jxr:jxr-no-fork', 'jxr:aggregate', 'jxr:test-jxr', 'jxr:test-jxr-no-fork', 'jxr:test-aggregate'
	'keytool:'              = 'keytool:clean', 'keytool:changeAlias', 'keytool:changeKeyPassword', 'keytool:changeStorePassword', 'keytool:deleteAlias', 'keytool:exportCertificate', 'keytool:generateCertificate', 'keytool:generateCertificateRequest', 'keytool:generateKeyPair', 'keytool:generateSecretKey', 'keytool:importCertificate', 'keytool:importKeyStore', 'keytool:list', 'keytool:printCertificate', 'keytool:printCertificateRequest', 'keytool:printCRLFile'
	'liberty:'              = 'liberty:create-server', 'liberty:start-server', 'liberty:stop-server', 'liberty:run-server', 'liberty:deploy', 'liberty:undeploy', 'liberty:java-dump-server', 'liberty:dump-server', 'liberty:package-server'
	'license:'              = 'license:format', 'license:check'
	'linkcheck:'            = 'linkcheck:linkcheck'
	'liquibase:'            = 'liquibase:changelogSync', 'liquibase:changelogSyncSQL', 'liquibase:clearCheckSums', 'liquibase:dbDoc', 'liquibase:diff', 'liquibase:dropAll', 'liquibase:help', 'liquibase:migrate', 'liquibase:listLocks', 'liquibase:migrateSQL', 'liquibase:releaseLocks', 'liquibase:rollback', 'liquibase:rollbackSQL', 'liquibase:status', 'liquibase:tag', 'liquibase:update', 'liquibase:updateSQL', 'liquibase:updateTestingRollback'
	'migration:'            = 'migration:bootstrap', 'migration:check', 'migration:down', 'migration:help', 'migration:init', 'migration:new', 'migration:pending', 'migration:repo', 'migration:script', 'migration:status', 'migration:status-report', 'migration:up', 'migration:version'
	'modello:'              = 'modello:xsd', 'modello:xdoc', 'modello:java', 'modello:xpp3-writer', 'modello:xpp3-reader', 'modello:xpp3-extended-reader', 'modello:xpp3-extended-writer', 'modello:dom4j-writer', 'modello:dom4j-reader', 'modello:stax-writer', 'modello:stax-reader', 'modello:jdom-writer', 'modello:jackson-writer', 'modello:jackson-reader', 'modello:jackson-extended-reader', 'modello:snakeyaml-writer', 'modello:snakeyaml-reader', 'modello:snakeyaml-extended-reader', 'modello:velocity', 'modello:converters'
	'nar:'                  = 'nar:help', 'nar:nar-assembly', 'nar:nar-compile', 'nar:nar-download', 'nar:nar-download-dependencies', 'nar:nar-gnu-configure', 'nar:nar-gnu-make', 'nar:nar-gnu-process', 'nar:nar-gnu-resources', 'nar:nar-integration-test', 'nar:nar-javah', 'nar:nar-package', 'nar:nar-prepare-package', 'nar:nar-process-libraries', 'nar:nar-resources', 'nar:nar-system-generate', 'nar:nar-test', 'nar:nar-test-unpack', 'nar:nar-testCompile', 'nar:nar-unpack', 'nar:nar-unpack-dependencies', 'nar:nar-validate', 'nar:nar-vcproj'
	'native:'               = 'native:initialize', 'native:unzipinc', 'native:compile', 'native:inczip', 'native:link', 'native:javah', 'native:ranlib', 'native:resource-compile', 'native:compile-message', 'native:manifest'
	'nexus-staging:'        = 'nexus-staging:close', 'nexus-staging:deploy', 'nexus-staging:deploy-staged', 'nexus-staging:deploy-staged-repository', 'nexus-staging:drop', 'nexus-staging:help', 'nexus-staging:promote', 'nexus-staging:rc-close', 'nexus-staging:rc-drop', 'nexus-staging:rc-list', 'nexus-staging:rc-list-profiles', 'nexus-staging:rc-promote', 'nexus-staging:rc-release', 'nexus-staging:release'
	'pdf:'                  = 'pdf:pdf'
	'pgpverify:'            = 'pgpverify:check', 'pgpverify:go-offline', 'pgpverify:help', 'pgpverify:show'
	'plugin-report:'        = 'plugin-report:report', 'plugin-report:report-no-fork'
	'plugin:'               = 'plugin:descriptor', 'plugin:addPluginArtifactMetadata', 'plugin:helpmojo', 'plugin:help'
	'pmd:'                  = 'pmd:pmd', 'pmd:aggregate-pmd', 'pmd:aggregate-pmd-no-fork', 'pmd:cpd', 'pmd:aggregate-cpd', 'pmd:check', 'pmd:aggregate-pmd-check', 'pmd:cpd-check', 'pmd:aggregate-cpd-check'
	'project-info-reports:' = 'project-info-reports:ci-management', 'project-info-reports:dependencies', 'project-info-reports:dependency-convergence', 'project-info-reports:dependency-info', 'project-info-reports:dependency-management', 'project-info-reports:distribution-management', 'project-info-reports:help', 'project-info-reports:index', 'project-info-reports:issue-management', 'project-info-reports:licenses', 'project-info-reports:mailing-lists', 'project-info-reports:modules', 'project-info-reports:plugin-management', 'project-info-reports:plugins', 'project-info-reports:team', 'project-info-reports:scm', 'project-info-reports:summary'
	'properties:'           = 'properties:read-project-properties', 'properties:write-project-properties', 'properties:write-active-profile-properties', 'properties:set-system-properties'
	'protobuf:'             = 'protobuf:compile', 'protobuf:compile-cpp', 'protobuf:compile-csharp', 'protobuf:compile-custom', 'protobuf:compile-javanano', 'protobuf:compile-js', 'protobuf:compile-python', 'protobuf:help', 'protobuf:test-compile', 'protobuf:test-compile-cpp', 'protobuf:test-compile-csharp', 'protobuf:test-compile-custom', 'protobuf:test-compile-javanano', 'protobuf:test-compile-js', 'protobuf:test-compile-python'
	'rar:'                  = 'rar:rar'
	'release:'              = 'release:clean', 'release:prepare', 'release:prepare-with-pom', 'release:rollback', 'release:perform', 'release:stage', 'release:branch', 'release:update-versions'
	'remote-resources:'     = 'remote-resources:bundle', 'remote-resources:process', 'remote-resources:aggregate'
	'resources:'            = 'resources:resources', 'resources:testResources', 'resources:copy-resources'
	'scala:'                = 'scala:add-source', 'scala:cc', 'scala:cctest', 'scala:compile', 'scala:console', 'scala:doc', 'scala:doc-jar', 'scala:help', 'scala:run', 'scala:script', 'scala:testCompile'
	'scm:'                  = 'scm:add', 'scm:bootstrap', 'scm:branch', 'scm:changelog', 'scm:check-local-modification', 'scm:checkin', 'scm:checkout', 'scm:diff', 'scm:edit', 'scm:export', 'scm:list', 'scm:remove', 'scm:status', 'scm:tag', 'scm:unedit', 'scm:update', 'scm:update-subprojects', 'scm:validate'
	'scripting:'            = 'scripting:eval'
	'shade:'                = 'shade:shade'
	'site:'                 = 'site:site', 'site:deploy', 'site:run', 'site:stage', 'site:stage-deploy', 'site:attach-descriptor', 'site:jar', 'site:effective-site'
	'sonar:'                = 'sonar:sonar', 'sonar:help'
	'source:'               = 'source:aggregate', 'source:jar', 'source:test-jar', 'source:jar-no-fork', 'source:test-jar-no-fork'
	'spotbugs:'             = 'spotbugs:spotbugs', 'spotbugs:check', 'spotbugs:gui', 'spotbugs:help'
	'spring-boot:'          = 'spring-boot:build-image', 'spring-boot:build-image-no-fork', 'spring-boot:build-info', 'spring-boot:help', 'spring-boot:process-aot', 'spring-boot:process-test-aot', 'spring-boot:repackage', 'spring-boot:run', 'spring-boot:start', 'spring-boot:stop', 'spring-boot:test-run'
	'sql:'                  = 'sql:execute'
	'stage:'                = 'stage:copy'
	'surefile:'             = 'surefire:test'
	'surefire-report:'      = 'surefire-report:report', 'surefire-report:report-only', 'surefire-report:failsafe-report-only'
	'taglist:'              = 'taglist:taglist'
	'tomcat:'               = 'tomcat:help', 'tomcat:start', 'tomcat:stop', 'tomcat:deploy', 'tomcat:undeploy'
	'tomcat6:'              = 'tomcat6:help', 'tomcat6:run', 'tomcat6:run-war', 'tomcat6:run-war-only', 'tomcat6:stop', 'tomcat6:deploy', 'tomcat6:redeploy', 'tomcat6:undeploy'
	'tomcat7:'              = 'tomcat7:help', 'tomcat7:run', 'tomcat7:run-war', 'tomcat7:run-war-only', 'tomcat7:deploy', 'tomcat7:redeploy', 'tomcat7:undeploy'
	'toolchains:'           = 'toolchains:select-jdk-toolchain', 'toolchains:display-discovered-jdk-toolchains', 'toolchains:generate-jdk-toolchains-xml', 'toolchains:toolchain'
	'verifier:'             = 'verifier:verify'
	'versions:'             = 'versions:compare-dependencies', 'versions:display-dependency-updates', 'versions:display-plugin-updates', 'versions:display-property-updates', 'versions:update-parent', 'versions:update-properties', 'versions:update-property', 'versions:update-child-modules', 'versions:lock-snapshots', 'versions:unlock-snapshots', 'versions:resolve-ranges', 'versions:set', 'versions:set-property', 'versions:use-releases', 'versions:use-next-releases', 'versions:use-latest-releases', 'versions:use-next-snapshots', 'versions:use-latest-snapshots', 'versions:use-next-versions', 'versions:use-latest-versions', 'versions:use-dep-version', 'versions:commit', 'versions:revert', 'versions:dependency-updates-report', 'versions:dependency-updates-aggregate-report', 'versions:plugin-updates-report', 'versions:plugin-updates-aggregate-report', 'versions:property-updates-report', 'versions:property-updates-aggregate-report', 'versions:parent-updates-report'
	'vertx:'                = 'vertx:init', 'vertx:runMod', 'vertx:pullInDeps', 'vertx:fatJar'
	'war:'                  = 'war:war', 'war:exploded', 'war:inplace'
	'wildfly:'              = 'wildfly:add-resource', 'wildfly:deploy', 'wildfly:deploy-only', 'wildfly:deploy-artifact', 'wildfly:package', 'wildfly:provision', 'wildfly:image', 'wildfly:redeploy', 'wildfly:redeploy-only', 'wildfly:undeploy', 'wildfly:dev', 'wildfly:run', 'wildfly:start', 'wildfly:shutdown', 'wildfly:execute-commands'
	'wrapper:'              = 'wrapper:wrapper'
}

# Maven completion data
$MvnCompletion, $MvnFullCompletion, $MvnPrefixesCompletion = {
	$goalsPrefixes = @()
	$goalsValues = @()
	foreach ($entry in $MvnPluginGoals.GetEnumerator()) {
		$goalsPrefixes += $entry.Key
		$goalsValues += $entry.Value
	}
	$MvnCompletion = ($MvnCommonLifecyclePhases | Sort-Object) + ($goalsPrefixes | Sort-Object)
	$MvnFullCompletion = ($MvnCommonLifecyclePhases + $goalsValues) -join '|'
	$MvnPrefixesCompletion = $goalsPrefixes -join '|'
	$MvnCompletion, $MvnFullCompletion, $MvnPrefixesCompletion
}.Invoke()

# Define system properties
$SystemProperties = @(
	'archetypeArtifactId=',
	'archetypeVersion=',
	'artifactId=',
	'build=',
	'checkstyle.skip=true',
	'detail=true',
	'enableCiProfile=true',
	'failIfNoTests',
	'findbugs.skip=true',
	'forkCount=0',
	'goal='
	'gpg.skip=true',
	'groupId=',
	'gwt.compiler.skip=true',
	'interactiveMode=false',
	'it.test=',
	'output=',
	'maven.build.cache.enabled=true',
	'maven.build.cache.remote.enabled=true',
	'maven.build.cache.lazyRestore=true',
	'maven.javadoc.skip=true',
	'maven.surefire.debug',
	'maven.test.skip=true',
	'performRelease=true',
	'pmd.skip=true',
	'plugin=',
	'skipITs',
	'skipTest',
	'test=',
	'tycho.mode=maven',
	'version='
)
$MvnSystemProperties = $SystemProperties | Sort-Object | ForEach-Object -Process { "-D$_" }

# Default filtering and result transformation for completion
$MvnDefaultFilterSB = { param($WordToComplete) { param($It) $It -like "$WordToComplete*" } }
$MvnDefaultResultSB = { param($It) [System.Management.Automation.CompletionResult]::new($It, $It, 'ParameterValue', $It) }

# Handle project-related completion results
$MvnProjectFilterSB = { param($WordToComplete) { param($It) ($It -like "$($WordToComplete -replace ":")*") -and ($It -ne "") } }
$MvnProjectResultSB = { param($It) [System.Management.Automation.CompletionResult]::new(":$It", ":$It", 'ParameterValue', ":$It") }

# Handle quoted result completion
$MvnQuotedResultSB = { param($It) [System.Management.Automation.CompletionResult]::new("`"$It`"", "`"$It`"", 'ParameterValue', "`"$It`"") }

# Find folders that include pom.xml.
function MvnProjects {
	param($Path)
	Get-ChildItem -File -Path $Path -Recurse -Name 'pom.xml' | Split-Path -Parent | Split-Path -Leaf
}

# Generate auto completion result from input source.
function MvnCompletionResult {
	param(
		$Source,
		$WordToComplete,
		$FilterScriptBlock = $MvnDefaultFilterSB,
		$ResultScriptBlock = $MvnDefaultResultSB
	)

	$FilterExpression = $FilterScriptBlock.Invoke($WordToComplete)
	Write-Output -InputObject -- $Source |
	Where-Object -FilterScript { $FilterExpression.Invoke($_) } |
	Sort-Object |
	ForEach-Object -Process { $ResultScriptBlock.Invoke($_) }
}

# Script Block for `Register-ArgumentCompleter`
$__mvn_completion = {
	param($wordToComplete, $commandAst, $cursorPosition)

	$lastIndex = $commandAst.CommandElements.Count - 1
	if ($lastIndex -gt 0) {
		$lastBlock = $commandAst.CommandElements[($lastIndex - 1)..$lastIndex] -join ' '
	} else {
		$lastBlock = $wordToComplete
	}

	# Handle completion based on the last block of the command
	switch -Regex -CaseSensitive ($lastBlock) {
		# Handle module names.
		"^(--(projects|resume-from)|-(pl|rf))\s+\:.*" {
			$mavenProjects = MvnProjects -Path "$((Get-Location).Path)"
			MvnCompletionResult -Source $mavenProjects -WordToComplete $wordToComplete -FilterScriptBlock $MvnProjectFilterSB -ResultScriptBlock $MvnProjectResultSB
			break
		}
		# Handle '--define' properties for each goals.
		"^.*--define\s*.*" {
			MvnCompletionResult -Source $SystemProperties -WordToComplete $wordToComplete -ResultScriptBlock $MvnQuotedResultSB
			break
		}
		# Handle all goals.
		default {
			switch -Regex -CaseSensitive ($wordToComplete) {
				# Handle long options for each goals.
				"^--.*" {
					MvnCompletionResult -Source $MvnLongOpts -WordToComplete $wordToComplete
					break
				}
				# Handle '-D' properties for each goals.
				"^-D.*" {
					MvnCompletionResult -Source $MvnSystemProperties -WordToComplete $wordToComplete -ResultScriptBlock $MvnQuotedResultSB
					break
				}
				# Handle options for each goals.
				"^-.*" {
					MvnCompletionResult -Source $MvnShortOpts -WordToComplete $wordToComplete
					break
				}
				# Handle plugin goals. for example `ant:`
				"^($MvnPrefixesCompletion).*" {
					$Prefix = $Matches[$Matches.Count - 1]
					MvnCompletionResult -Source $MvnPluginGoals[$Prefix] -WordToComplete $wordToComplete
					break
				}
				default {
					MvnCompletionResult -Source $MvnCompletion -WordToComplete $wordToComplete
				}
			}
		}
	}
}

Register-ArgumentCompleter -Native -CommandName 'mvn' -ScriptBlock $__mvn_completion
