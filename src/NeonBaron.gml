///@package io.alkapivo.neon-baron

function _NeonBaron() constructor {
  
  ///@private
  ///@type {?Struct}
  _assets = null  
  
  ///@private
  ///@type {?CLIParamParser}
  _cliParser = null

  ///@return {Struct}
  static assets = function() {
    if (this._assets == null) {
      this._assets = {
        textures: new Map(String, TextureTemplate),
      }
    }
    
    return this._assets
  }

  ///@return {CLIParamParser}
  static cliParser = function() {
    if (this._cliParser == null) {
      this._cliParser = new CLIParamParser({
        cliParams: new Array(CLIParam, [
          new CLIParam({
            name: "-t",
            fullName: "--test",
            description: "Run tests from test suite",
            args: [
              {
                name: "file",
                type: "String",
                description: "Path to test suite JSON"
              }
            ],
            handler: function(args) {
              Logger.debug("CLIParamParser", $"Run --test {args.get(0)}")
              Beans.get(BeanTestRunner).push(args.get(0))
            },
          }),
        ])
      })
    }
    
    return this._cliParser
  }
  
  ///@param {String} [layerName]
  ///@param {Number} [layerDefaultDepth]
  ///@return {NeonBaron}
  static run = function(layerName = "instance_main", layerDefaultDepth = 100) {
    initBeans()
    initGPU()
    initGMTF()
    
    Core.loadProperties(FileUtil.get($"{working_directory}core-properties.json"))
    Core.loadProperties(FileUtil.get($"{working_directory}neon-baron-properties.json"))

    var layerId = Scene.fetchLayer(layerName, layerDefaultDepth)

    if (!Beans.exists(BeanDeltaTimeService)) {
      Beans.add(Beans.factory(BeanDeltaTimeService, GMServiceInstance, layerId,
        new DeltaTimeService()))
    }

    if (!Beans.exists(BeanFileService)) {
      Beans.add(Beans.factory(BeanFileService, GMServiceInstance, layerId,
        new FileService({
          dispatcher: {
            limit: Core.getProperty("neon-baron.files-service.dispatcher.limit", 1),
          }
        })))
    }

    if (!Beans.exists(BeanTextureService)) {
      Beans.add(Beans.factory(BeanTextureService, GMServiceInstance, layerId,
        new TextureService({
          getStaticTemplates: function() {
            return NeonBaron.assets().textures
          },
        })))
    }
    
    if (!Beans.exists(BeanSoundService)) {
      Beans.add(Beans.factory(BeanSoundService, GMServiceInstance, layerId,
        new SoundService()))
    }

    if (!Beans.exists(BeanDialogueDesignerService)) {
      Beans.add(Beans.factory(BeanDialogueDesignerService, GMServiceInstance, layerId,
        new DialogueDesignerService({
          handlers: new Map(String, Callable, {
            "QUIT": function(data) {
              Beans.get(BeanDialogueDesignerService).close()
            },
            //"LOAD_VISU_TRACK": function(data) {
            //  Beans.get(BeanVisuController).send(new Event("load", {
            //    manifest: FileUtil.get(data.path),
            //    autoplay: true,
            //  }))
            //},
            "GAME_END": function(data) {
              game_end()
            },
          }),
        })))
    }

    if (!Beans.exists(BeanTestRunner)) {
      Beans.add(Beans.factory(BeanTestRunner, GMServiceInstance, layerId,
        new TestRunner()))
    }

    //if (!Beans.exists(BeanGameController)) {
    //  Beans.add(Beans.factory(BeanGameController, GMControllerInstance, layerId,
    //    new GameController(layerName)))
    //}

    if (!Beans.exists(BeanTopDownController)) {
      Beans.add(Beans.factory(BeanTopDownController, GMControllerInstance, layerId,
        new TopDownController(layerName)))
    }

    if (!Beans.exists(BeanNeonBaronController)) {
      Beans.add(Beans.factory(BeanNeonBaronController, GMControllerInstance, layerId,
        new NeonBaronController(layerName)))
    }

    this.cliParser().parse()
    
    return this
  }
}
global.__NeonBaron = new _NeonBaron()
#macro NeonBaron global.__NeonBaron