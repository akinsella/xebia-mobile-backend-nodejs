module.exports = function(grunt) {

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-simple-mocha');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-copy');

	grunt.initConfig({
		clean:{
			dev: {
				src: ["build"]
			}
		},
		copy:{
			dev:{
				files: [
					{
						expand: true,
						flatten: false,
						cwd: 'src/javascript/',
						src: ['**/*.js'],
						dest: 'build/'
					},
					{
						expand: true,
						flatten: false,
						cwd: 'public/',
						src: ['**/*'],
						dest: 'build/public/'
					}
				]
			}
		},
		coffee:{
			dev:{
				options: {
					sourceMap: true
				},
				expand: true,
				flatten: false,
				cwd: 'src/coffee/',
				src: ['**/*.coffee'],
				dest: 'build/',
				ext: '.js'
			},
			test:{
				options: {
					sourceMap: true
				},
				expand: true,
				flatten: false,
				cwd: 'test/coffee/',
				src: ['**/*.coffee'],
				dest: 'build/test/',
				ext: '.js'
			}
		},
		simplemocha:{
			dev:{
				src:"test/javascript/*.js",
				options:{
					reporter: 'spec',
					slow: 200,
					timeout: 1000
				}
			}
		},
		watch:{
			all:{
				files:['src/coffee/*', 'test/coffee/*.coffee'],
				tasks:['buildDev', 'buildTest', 'test']
			}
		}
	});

	grunt.registerTask('test', 'simplemocha:dev');
	grunt.registerTask('buildDev', ['copy:dev', 'coffee:dev']);
	grunt.registerTask('buildTest', 'coffee:test');
	grunt.registerTask('build', ['buildDev', 'buildTest']);
	grunt.registerTask('watch', ['build', 'test', 'watch:all']);

};