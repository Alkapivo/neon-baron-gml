///@package io.alkapivo.neon-baron

function _NeonBaron() constructor {
  
  ///@private
  ///@type {?Struct}
  _assets = null  
  
  ///@return {Struct}
  static assets = function() {
    if (this._assets == null) {
      this._assets = {
        textures: new Map(String, TextureTemplate),
      }
    }
    
    return _assets
  }
  
  ///@param {String} [layerName]
  ///@param {Number} [layerDefaultDepth]
  ///@return {NeonBaron}
  static run = function(layerName = "instance_main", layerDefaultDepth = 100) {
    initGPU()
    initBeans()
    GMTFContext = new _GMTFContext()
    Core.loadProperties(FileUtil.get($"{working_directory}core-properties.json"))
    Core.loadProperties(FileUtil.get($"{working_directory}neon-baron-properties.json"))
    Assert.isType(layerName, String, "layerName must be a string")
    var layerId = layer_get_id(layerName)
    if (layerId == -1) {
      layerId = layer_create(Assert.isType(layerDefaultDepth, Number), layerName)
    }

    if (!Beans.exists(BeanDeltaTimeService)) {
      Beans.add(BeanDeltaTimeService, new Bean(DeltaTimeService,
        GMObjectUtil.factoryGMObject(
          GMServiceInstance, 
          layerId, 0, 0, 
          new DeltaTimeService()
        )
      ))
    }

    if (!Beans.exists(BeanFileService)) {
      Beans.add(BeanFileService, new Bean(FileService,
        GMObjectUtil.factoryGMObject(
          GMServiceInstance, 
          layerId, 0, 0, 
          new FileService({ 
            dispatcher: { 
              limit: Core.getProperty("neon-baron.files-service.dispatcher.limit", 1),
            }
          })
        )
      ))
    }
    
    if (!Beans.exists(BeanTextureService)) {
      Beans.add(BeanTextureService, new Bean(TextureService,
        GMObjectUtil.factoryGMObject(
          GMServiceInstance, 
          layerId, 0, 0, 
          new TextureService({
            getStaticTemplates: function() {
              return NeonBaron.assets().textures
            },
          })
        )
      ))
    }
    
    if (!Beans.exists(BeanSoundService)) {
      Beans.add(BeanSoundService, new Bean(SoundService,
        GMObjectUtil.factoryGMObject(
          GMServiceInstance, 
          layerId, 0, 0, 
          new SoundService()
        )
      ))
    }

    if (!Beans.exists(BeanDialogueDesignerService)) {
      Beans.add(BeanDialogueDesignerService , new Bean(DialogueDesignerService,
        GMObjectUtil.factoryGMObject(
          GMServiceInstance, 
          layerId, 0, 0, 
          new DialogueDesignerService({
            handlers: new Map(String, Callable, {
              "QUIT": function(data) {
                Beans.get(BeanDialogueDesignerService).close()
              },
              "LOAD_VISU_TRACK": function(data) {
                Core.print("Mockup LOAD_VISU_TRACK")
                //Beans.get(BeanVisuController).send(new Event("load", {
                //  manifest: FileUtil.get(data.path),
                //  autoplay: true,
                //}))
              },
              "GAME_END": function(data) {
                game_end()
              },
            }),
          })
        )
      ))
    }
    
    if (!Beans.exists(BeanTestRunner)) {
      Beans.add(BeanTestRunner, new Bean(TestRunner,
        GMObjectUtil.factoryGMObject(
          GMServiceInstance, 
          layerId, 0, 0, 
          new TestRunner()
        )
      ))
    }

    //Beans.add(BeanGameController, new Bean(GameController,
    //  GMObjectUtil.factoryGMObject(
    //    GMControllerInstance, 
    //    layerId, 0, 0, 
    //    new GameController(layerName)
    //  )
    //))

    Beans.add(BeanTopDownController, new Bean(TopDownController,
      GMObjectUtil.factoryGMObject(
        GMControllerInstance, 
        layerId, 0, 0, 
        new TopDownController(layerName)
      )
    ))
    
    Beans.add(BeanNeonBaronController, new Bean(NeonBaronController,
      GMObjectUtil.factoryGMObject(
        GMControllerInstance, 
        layerId, 0, 0, 
        new NeonBaronController(layerName)
      )
    ))

    var parser = new CLIParamParser({
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
    parser.parse()
    
    return this
  }
}
global.__NeonBaron = new _NeonBaron()
#macro NeonBaron global.__NeonBaron