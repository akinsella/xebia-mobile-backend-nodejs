module.exports = function(grunt) {

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-simple-mocha');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-mocha-cov');
	grunt.loadNpmTasks('grunt-coffeelint');
	grunt.loadNpmTasks('grunt-shell');
	grunt.loadNpmTasks('grunt-contrib-sass');

	grunt.initConfig({
		clean:{
			dev: {
				src: ["build", "coverage"]
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
						cwd: 'data/',
						src: ['**/*'],
						dest: 'build/data/'
					}
				]
			},
			'public':{
				files: [
					{
						expand: true,
						flatten: false,
						cwd: 'public/',
						src: ['**/*'],
						dest: 'build/public/'
					}
				]
			},
			test:{
				files: [
					{
						expand: true,
						flatten: false,
						cwd: 'test/data/',
						src: ['**/*'],
						dest: 'build/test/data/'
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
				cwd: 'test/coffee/',
				src: ['**/*.coffee'],
				dest: 'build/test/',
				ext: '.js'
			}
		},
		sass: {
			dev: {
				files: [{
					expand: true,
					cwd: 'src/sass',
					src: ['*.scss'],
					dest: 'build/public/styles',
					ext: '.css'
				}]
			}
		},
		livereload: {
			files: [
				"Gruntfile.coffee",
				"public/scripts/*.js",
				"public/styles/*.css",
				"public/errors/*.html",
				"public/partials/**/*.html",
				"public/images/**/*.{png,jpg,jpeg,gif,webp,svg}"],
			options:{
				livereload: true
			}
		},
		coffeelint: {
			dev: {
				files: {
					src: ['src/**/*.coffee']
				},
				options: {
					'no_trailing_whitespace': {
						'level': 'error'
					}
				}
			},
			test: {
				files: {
					src: ['test/**/*.coffee']
				},
				options: {
					'no_trailing_whitespace': {
						'level': 'error'
					}
				}
			}
		},
		simplemocha:{
			dev:{
				src:"build/test/*.js",
				options:{
					reporter: 'spec',
					slow: 200,
					timeout: 1000
				}
			}
		},
		watch: {
			coffee_dev: {
				files:['src/coffee/**/*.coffee'],
				tasks: ["coffee:dev"]
			},
			coffee_test: {
				files:['test/coffee/**/*.coffee'],
				tasks: ["coffee:test"]
			},
			copy_dev: {
				files:['src/javascript/**/*.js', 'data/**/*.*'],
				tasks: ["copy:dev"]
			},
			copy_test: {
				files:['test/data/**/*.*'],
				tasks: ["copy:test"]
			},
			sass_dev: {
				files:['public/styles/sass/**/*.scss'],
				tasks: ["sass:dev"]
			},
			public_dev: {
				files:['public/**/*.*'],
				tasks: ["copy:public"]
			}
		},
		shell: {                                // Task
			cover: {                            // Target
				options: {                      // Options
					stdout: true
				},
				command: [
					'mkdir coverage',
					'istanbul instrument -x "public/**" -x "test/**" --output build-cov build -v',
					'cp -r build/test build-cov/test',
					'ISTANBUL_REPORTERS=text-summary,cobertura,lcov ./node_modules/.bin/mocha --reporter mocha-istanbul --timeout 20s --debug build-cov/test',
					'mv lcov.info coverage',
					'mv lcov-report coverage',
					'mv cobertura-coverage.xml coverage',
					'rm -rf build-cov'
				].join('&&')
			}
		}
	});

	grunt.registerTask('coverage', ['shell:cover']);
	grunt.registerTask('test', 'simplemocha:dev');
	grunt.registerTask('buildDev', ['copy:dev', 'copy:public', 'coffee:dev'/*, 'coffeelint:dev'*/]);
	grunt.registerTask('buildTest', ['copy:test', 'coffee:test'/*, 'coffeelint:test'*/]);
	grunt.registerTask('build', ['buildDev', 'buildTest']);

};