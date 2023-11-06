#!groovy

import jenkins.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def installed = false
def initialized = false

def pluginParameter = System.getenv("JENKINS_PLUGINS")
def plugins = pluginParameter.split(",")

def instance = Jenkins.getInstance()

def pluginManager = instance.getPluginManager()

def installPlugins = {
    logger.info("Installing plugins...")
    plugins.each { plugin ->
        logger.info("Installing plugin: ${plugin}")
        def pluginWrapper = pluginManager.getPlugin(plugin)
        if (pluginWrapper == null) {
            logger.info("Plugin not found: ${plugin}")
        } else if (!pluginWrapper.isEnabled()) {
            logger.info("Enabling plugin: ${plugin}")
            pluginWrapper.enable()
            installed = true
        }
    }
}

def initialize = {
    logger.info("Initializing Jenkins...")
    instance.save()
    initialized = true
}

logger.info("Checking plugins...")
if (pluginManager.getPlugins().size() == 0) {
    installPlugins()
    initialize()
} else {
    plugins.each { plugin ->
        def pluginWrapper = pluginManager.getPlugin(plugin)
        if (pluginWrapper == null) {
            logger.info("Plugin not found: ${plugin}")
            installPlugins()
            initialize()
        } else if (!pluginWrapper.isEnabled()) {
            logger.info("Enabling plugin: ${plugin}")
            pluginWrapper.enable()
            installed = true
        }
    }
    if (installed) {
        initialize()
    }
}

if (!initialized) {
    logger.info("Jenkins already initialized.")
}