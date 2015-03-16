# NOTE: borrowed from fog-aws rubygem - lib/fog/aws/models/compute/flavors.rb
module Fog
  module Compute
    class AWS
      FLAVORS = [
        {
          :id                      => 't1.micro',
          :name                    => 'Micro Instance',
          :bits                    => 0,
          :cores                   => 2,
          :disk                    => 0,
          :ram                     => 613,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 't2.micro',
          :name                    => 'Micro Instance',
          :bits                    => 64,
          :cores                   => 1,
          :disk                    => 0,
          :ram                     => 1024,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 't2.small',
          :name                    => 'Micro Instance',
          :bits                    => 64,
          :cores                   => 1,
          :disk                    => 0,
          :ram                     => 2048,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 't2.medium',
          :name                    => 'Micro Instance',
          :bits                    => 64,
          :cores                   => 2,
          :disk                    => 0,
          :ram                     => 4096,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 'm1.small',
          :name                    => 'Small Instance',
          :bits                    => 32,
          :cores                   => 1,
          :disk                    => 160,
          :ram                     => 1740.8,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 1
        },
        {
          :id                      => 'm1.medium',
          :name                    => 'Medium Instance',
          :bits                    => 32,
          :cores                   => 2,
          :disk                    => 400,
          :ram                     => 3750,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 1
        },
        {
          :id                      => 'm1.large',
          :name                    => 'Large Instance',
          :bits                    => 64,
          :cores                   => 4,
          :disk                    => 850,
          :ram                     => 7680,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'm1.xlarge',
          :name                    => 'Extra Large Instance',
          :bits                    => 64,
          :cores                   => 8,
          :disk                    => 1690,
          :ram                     => 15360,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 4
        },
        {
          :id                      =>  'c1.medium',
          :bits                    => 32,
          :cores                   => 5,
          :disk                    => 350,
          :name                    => 'High-CPU Medium',
          :ram                     => 1740.8,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 1
        },
        {
          :id                      => 'c1.xlarge',
          :name                    => 'High-CPU Extra Large',
          :bits                    => 64,
          :cores                   => 20,
          :disk                    => 1690,
          :ram                     => 7168,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 4
        },
        {
          :id                      => 'c3.large',
          :name                    => 'C3 Large',
          :bits                    => 64,
          :cores                   => 7,
          :disk                    => 32,
          :ram                     => 3750,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c3.xlarge',
          :name                    => 'C3 Extra Large',
          :bits                    => 64,
          :cores                   => 14,
          :disk                    => 80,
          :ram                     => 7168,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c3.2xlarge',
          :name                    => 'C3 Double Extra Large',
          :bits                    => 64,
          :cores                   => 28,
          :disk                    => 160,
          :ram                     => 15360,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c3.4xlarge',
          :name                    => 'C3 Quadruple Extra Large',
          :bits                    => 64,
          :cores                   => 55,
          :disk                    => 320,
          :ram                     => 30720,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c3.8xlarge',
          :name                    => 'C3 Eight Extra Large',
          :bits                    => 64,
          :cores                   => 108,
          :disk                    => 640,
          :ram                     => 61440,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c4.large',
          :name                    => 'C4 Large',
          :bits                    => 64,
          :cores                   => 7,
          :disk                    => 32,
          :ram                     => 3750,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c4.xlarge',
          :name                    => 'C4 Extra Large',
          :bits                    => 64,
          :cores                   => 14,
          :disk                    => 80,
          :ram                     => 7168,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c4.2xlarge',
          :name                    => 'C4 Double Extra Large',
          :bits                    => 64,
          :cores                   => 28,
          :disk                    => 160,
          :ram                     => 15360,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c4.4xlarge',
          :name                    => 'C4 Quadruple Extra Large',
          :bits                    => 64,
          :cores                   => 55,
          :disk                    => 320,
          :ram                     => 30720,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'c4.8xlarge',
          :name                    => 'C4 Eight Extra Large',
          :bits                    => 64,
          :cores                   => 122,
          :disk                    => 640,
          :ram                     => 61440,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'g2.2xlarge',
          :name                    => 'GPU Double Extra Large',
          :bits                    => 64,
          :cores                   => 26,
          :disk                    => 60,
          :ram                     => 15360,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 'hs1.8xlarge',
          :name                    => 'High Storage Eight Extra Large',
          :bits                    => 64,
          :cores                   => 35,
          :disk                    => 50331648,
          :ram                     => 119808,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 24
        },
        {
          :id                      => 'm2.xlarge',
          :name                    => 'High-Memory Extra Large',
          :bits                    => 64,
          :cores                   => 6.5,
          :disk                    => 420,
          :ram                     => 17510.4,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 1
        },
        {
          :id                      =>  'm2.2xlarge',
          :name                    => 'High Memory Double Extra Large',
          :bits                    => 64,
          :cores                   => 13,
          :disk                    => 850,
          :ram                     => 35020.8,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 1
        },
        {
          :id                      => 'm2.4xlarge',
          :name                    => 'High Memory Quadruple Extra Large',
          :bits                    => 64,
          :cores                   => 26,
          :disk                    => 1690,
          :ram                     => 70041.6,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'cr1.8xlarge',
          :name                    => 'High Memory Eight Extra Large',
          :bits                    => 64,
          :cores                   => 88,
          :disk                    => 240,
          :ram                     => 249856,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'm3.medium',
          :name                    => 'M3 Medium',
          :bits                    => 64,
          :cores                   => 3,
          :disk                    => 4,
          :ram                     => 3840,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 'm3.large',
          :name                    => 'M3 Large',
          :bits                    => 64,
          :cores                   => 6.5,
          :disk                    => 32,
          :ram                     => 7168,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 1
        },
        {
          :id                      => 'm3.xlarge',
          :name                    => 'M3 Extra Large',
          :bits                    => 64,
          :cores                   => 13,
          :disk                    => 80,
          :ram                     => 15360,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'm3.2xlarge',
          :name                    => 'M3 Double Extra Large',
          :bits                    => 64,
          :cores                   => 26,
          :disk                    => 160,
          :ram                     => 30720,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => "hi1.4xlarge",
          :name                    => "High I/O Quadruple Extra Large Instance",
          :bits                    => 64,
          :cores                   =>   35,
          :disk                    => 2048,
          :ram                     => 61952,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'cc1.4xlarge',
          :name                    => 'Cluster Compute Quadruple Extra Large',
          :bits                    => 64,
          :cores                   => 33.5,
          :disk                    => 1690,
          :ram                     => 23552,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 0
        },
        {
          :id                      => 'cc2.8xlarge',
          :name                    => 'Cluster Compute Eight Extra Large',
          :bits                    => 64,
          :cores                   => 88,
          :disk                    => 3370,
          :ram                     => 61952,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 4
        },
        {
          :id                      => 'cg1.4xlarge',
          :name                    => 'Cluster GPU Quadruple Extra Large',
          :bits                    => 64,
          :cores                   => 33.5,
          :disk                    => 1690,
          :ram                     => 22528,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'i2.xlarge',
          :name                    => 'I2 Extra Large',
          :bits                    => 64,
          :cores                   => 14,
          :disk                    => 800,
          :ram                     => 31232,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 1
        },
        {
          :id                      => 'i2.2xlarge',
          :name                    => 'I2 Double Extra Large',
          :bits                    => 64,
          :cores                   => 27,
          :disk                    => 1600,
          :ram                     => 62464,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        },
        {
          :id                      => 'i2.4xlarge',
          :name                    => 'I2 Quadruple Extra Large',
          :bits                    => 64,
          :cores                   => 53,
          :disk                    => 3200,
          :ram                     => 124928,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 4
        },
        {
          :id                      => 'i2.8xlarge',
          :name                    => 'I2 Eight Extra Large',
          :bits                    => 64,
          :cores                   => 104,
          :disk                    => 6400,
          :ram                     => 249856,
          :ebs_optimized_available => false,
          :instance_store_volumes  => 8
        },
        {
          :id                      => "r3.large",
          :name                    => "R3 Large",
          :bits                    => 64,
          :cores                   => 2,
          :ram                     => 15360,
          :disk                    => 32,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 1
        },
        {
          :id                      => "r3.xlarge",
          :name                    => "R3 Extra Large",
          :bits                    => 64,
          :cores                   => 4,
          :ram                     => 31232,
          :disk                    => 80,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 1
        },
        {
          :id                      => "r3.2xlarge",
          :name                    => "R3 Double Extra Large",
          :bits                    => 64,
          :cores                   => 8,
          :ram                     => 62464,
          :disk                    => 160,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 1
        },
        {
          :id                      => "r3.4xlarge",
          :name                    => "R3 Quadruple Extra Large",
          :bits                    => 64,
          :cores                   => 16,
          :ram                     => 124928,
          :disk                    => 320,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 1
        },
        {
          :id                      => "r3.8xlarge",
          :name                    => "R3 Eight Extra Large",
          :bits                    => 64,
          :cores                   => 32,
          :ram                     => 249856,
          :disk                    => 640,
          :ebs_optimized_available => true,
          :instance_store_volumes  => 2
        }
      ]
    end
  end
end
